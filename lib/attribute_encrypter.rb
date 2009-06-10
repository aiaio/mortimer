module AttributeEncrypter

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods

    # Create a crypted attribute.
    #   class Entry < ActiveRecord::Base
    #     has_crypted_attribute :password
    #
    # Optional     
    #  TODO: Error handling on options, attribute name, attribute already exists?, permitted users not defined?, encrypter table lacks appropriate attributes?   
    def has_crypted_attribute(name, options={})
      create_crypted_attribute(name, options)
      build_crypted_attribute_associations
      define_crypted_attribute_methods_and_callbacks
      one_time_crypted_setup
    end  

    # Hash of crypted attributes defined on this model.
    def crypted_attributes
      read_inheritable_attribute(:crypted_attributes) || write_inheritable_attribute(:crypted_attributes, {})
    end

    protected

      # Pointer to the current crypted attribute; this way, 
      # it's not necessary to pass this value around.
      def current_crypted_attribute
        crypted_attributes[@current_attribute]
      end

      # Includes instance methods and defines one callback.
      def one_time_crypted_setup
        return unless self.crypted_attributes.size > 1
        self.send(:include, InstanceMethods)
        self.send(:include, EncryptionMethods)
        self.after_save :encrypt_attributes_for_permitted_users
      end  
      
      # Defines the crypted attribute's class, and adds
      # an entry to the inheritable crypted_attributes hash.
      def create_crypted_attribute(name, options={})
        attribute_klass = create_crypted_attribute_class(name)
        definition = {:name   => name,
                      :plural => name.to_s.pluralize,
                      :encrypter_name => options[:encrypter_class_name] || "User", 
                      :attribute_class => attribute_klass}
        write_inheritable_hash(:crypted_attributes, name => definition)
        @current_attribute = name
      end

      # Creates a subclass of CryptedAttribute for the new attribute, 
      # adds an attr_accessor for the attribute, and a callback for saving 
      # encrypted attributes if this is the first encrypted attribute added. 
      def create_crypted_attribute_class(name)
        class_name = name.to_s.camelize + "CryptedAttribute"
        klass = Object.const_set(class_name, Class.new(CryptedAttribute))
        return klass
      end  

      # Defines associations equivalent to the following:
      #   class EncryptedUsername < EncryptedAttribute 
      #     belongs_to :user, class_name => "User", :foreign_key => :encrypter_id 
      #   end
      #
      #   class Entry
      #     has_many :usernames, :as => encryptable
      #   end  
      def build_crypted_attribute_associations
        current_crypted_attribute[:attribute_class].belongs_to(:encrypter, 
          :class_name => current_crypted_attribute[:encrypter_name], 
          :foreign_key => :encrypter_id)
        self.has_many current_crypted_attribute[:plural], :as => :encryptable
      end

      # Adds attribute_updated? and attr_accessor. 
      def define_crypted_attribute_methods_and_callbacks
        define_attribute_updated
        self.send(:attr_accessor, current_crypted_attribute[:name])
      end  

      # Instance method to determine whether the attribute needs to be
      # created or updated (new_record? or not blank).
      def define_attribute_updated
        name = current_crypted_attribute[:name]
        method_body = <<-EOB
          protected
          def #{name}_updated?
            self.new_record? || !self.#{name}.blank?
          end
        EOB
        self.class_eval(method_body)
      end  
   end

  module InstanceMethods
                 
    # Decrypt any encrypted attributes for the given
    # permitted user, and place the decrypted values
    # in their corresponding virtual (non-saved) attributes.
    def decrypt_attributes_for(user, user_password) 
      raise PermissionsError if user_crypted_attributes(user).blank?

      user_crypted_attributes(user).each do |crypted_attr|
        next if crypted_attr.nil? # Don't try to decrypt if nil.
        self.send(crypted_attr.setter, asymmetric_decrypt(crypted_attr.data, user.crypted_private_key, user_password))
      end

      rescue OpenSSL::CipherError
        raise PermissionsError
    end 

    # Grant a new user acces to the crypted attributes.
    # Requires a user who already has access to allow decrypt.
    def create_crypted_attributes_for(new_user, decrypting_user, decrypting_user_password)
      decrypt_attributes_for(decrypting_user, decrypting_user_password)
      self.class.crypted_attributes.each_value do |attr|
        plain_text = self.send(attr[:name]) || ""
        generate_crypted_attribute(attr[:attribute_class], plain_text, new_user)
      end  
    end

    # Defines a method to destroy every crypted attribute
    # associated with this class for the given user.
    def destroy_crypted_attributes_for(user)
      crypted = CryptedAttribute.for_encrypter(user).for_encryptable(self)
      crypted.map(&:destroy)  
    end

    protected
      # Defines a method encrypt all attributes
      # for each of the permitted users.
      def encrypt_attributes_for_permitted_users 
        self.class.crypted_attributes.each_value do |attr|
          next unless self.send("#{attr[:name]}_updated?")
          permitted_users.each do |user|
            attr_class = attr[:attribute_class]
            attr_text  = self.send(attr[:name]) || ""
            record  = attr_class.for_encrypter(user).for_encryptable(self).first || attr_class 
            generate_crypted_attribute(record, attr_text, user)
          end
        end  
      end  

      # Supply a crypted attribute record or the class corresponding
      # to the crypted attribute (here, record). Will either update the given
      # record or create a new record of the given class.
      def generate_crypted_attribute(record, plain_text, user)
        crypted = asymmetric_encrypt(plain_text, user.public_key)
        if record.respond_to?(:update_attributes)
          record.update_attributes(:data => crypted)
          record
        else # record is a class
          record.create(:data => crypted, :encrypter => user, :encryptable => self)
        end
      end  

      # Aggregates all encrypted attributes for the given user
      # on the current class.
      def user_crypted_attributes(user)
        @user_encrypted_attributes ||= self.class.crypted_attributes.values.map do |attr|
          attr[:attribute_class].for_encrypter(user).for_encryptable(self).first
        end.select {|a| !a.nil?}  
      end  
       
  end  
  
  module EncryptionMethods
        
    protected
      # Encrypts the data with a given public key.
      def asymmetric_encrypt(plain_text_data, public_key)
        sentry.encrypt_to_base64_with_key(plain_text_data, public_key)
      end
      
      # Decrypts given an encrypted private key and private-key's password.
      def asymmetric_decrypt(crypted_data, crypted_key, crypted_keypass, keypass_key=SESSION_PASSWORD_KEY)
        crypted_key.chomp!
        sentry.decrypt_from_base64_with_key(crypted_data, crypted_key, crypted_keypass, keypass_key)
      end
      
      # Class handling encryption and decryption.
      def sentry
        Sentry::AsymmetricSentry
      end
  end
end

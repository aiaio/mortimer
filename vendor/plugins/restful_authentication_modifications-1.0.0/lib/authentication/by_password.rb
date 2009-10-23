module Authentication
  module ByPassword
    def self.included(recipient)
      recipient.extend(ModelClassMethods)
      recipient.class_eval do
        include ModelInstanceMethods
        
        # Virtual attribute for the unencrypted password
        attr_accessor :password

        # Virtual attribute for the old unencrypted password, used to 
        # decrypt the user's private key to reencrypt with the new password.
        attr_accessor :old_password

        validates_presence_of     :password,                   :if => :password_required?
        validates_presence_of     :password_confirmation,      :if => :password_required?
        validates_confirmation_of :password,                   :if => :password_required?

        validate :validate_password

        # Changes password validation.
        before_save :encrypt_password
      end
    end # #included directives

    module ModelInstanceMethods

      # This method needs modification to recrypt the private key
      # unless we have a new record or are resetting a user's password.
      def encrypt_password
        return if password.blank?
        self.salt = self.class.make_token if new_record?
        self.crypted_password = encrypt(password)
        recrypt_private_key unless new_record? || resetting_password?
      end

      # Since this system's strength depends on the strength of its passwords,
      # strict validation is enforced.
      def validate_password
        return unless password_required?
        if password =~ /^.{10,40}$/ &&  # Minimum ten characters, maximum for
           password =~ /[A-Z]/ &&  # At least one uppercase letter
           password =~ /([0-10|\W]).*([0-10|\W])/ # At least two non-word characters or numbers
           return true
        else
          self.errors.add(:password, "must be at least 10 characters long, contain both lower- and upper-case letters, and have at least two symbols or numbers.")
          return false
        end  
      end

    end 
  end
end

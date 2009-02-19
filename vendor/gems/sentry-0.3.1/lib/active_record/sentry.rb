module ActiveRecord # :nodoc:
  module Sentry
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
  
    module ClassMethods
      def generates_crypted(attr_name, options = {})
        mode = options[:mode] || :sha
        case mode
          when :sha
            generates_crypted_hash_of(attr_name)
          when :asymmetric, :asymmetrical
            asymmetrically_encrypts(attr_name)
          when :symmetric, :symmetrical
            symmetrically_encrypts(attr_name)
        end
      end 
    
      def generates_crypted_hash_of(attribute)
        before_validation ::Sentry::ShaSentry.new(attribute)
        attr_accessor attribute
      end

      def asymmetrically_encrypts(attr_name)
        temp_sentry = ::Sentry::AsymmetricSentryCallback.new(attr_name)
        before_validation temp_sentry
        after_save temp_sentry
      
        define_method(attr_name) do |*optional|
          send("#{attr_name}!", *optional) rescue nil
        end
      
        define_method("#{attr_name}!") do |*optional|
          return decrypted_values[attr_name] unless decrypted_values[attr_name].nil?
          return nil if send("crypted_#{attr_name}").nil?
          key = optional.shift
          ::Sentry::AsymmetricSentry.decrypt_from_base64(send("crypted_#{attr_name}"), key)
        end
      
        define_method("#{attr_name}=") do |value|
          decrypted_values[attr_name] = value
          nil
        end
      
        private
        define_method(:decrypted_values) do
          @decrypted_values ||= {}
        end
      end

      def symmetrically_encrypts(attr_name)
        temp_sentry = ::Sentry::SymmetricSentryCallback.new(attr_name)
        before_validation temp_sentry
        after_save temp_sentry

        define_method(attr_name) do
          send("#{attr_name}!") rescue nil
        end

        define_method("#{attr_name}!") do
          return decrypted_values[attr_name] unless decrypted_values[attr_name].nil?
          return nil if send("crypted_#{attr_name}").nil?
          ::Sentry::SymmetricSentry.decrypt_from_base64(send("crypted_#{attr_name}"))
        end
      
        define_method("#{attr_name}=") do |value|
          decrypted_values[attr_name] = value
          nil
        end
      
        private
        define_method(:decrypted_values) do
          @decrypted_values ||= {}
        end
      end
    end
  end
end

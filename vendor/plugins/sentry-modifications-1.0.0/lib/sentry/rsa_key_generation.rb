module Sentry
  module RsaKeyGeneration
    def self.included(klass)
      klass.class_eval do
        include ModelInstanceMethods
        before_create :generate_rsa_keys
      end
    end
    
    module ModelInstanceMethods

      private

      def generate_rsa_keys
        keys = Sentry::AsymmetricSentry.generate_random_rsa_key(password)
        self.public_key  = keys[:public].to_s
        self.crypted_private_key = keys[:private].to_s.chomp
      end   

      def recrypt_private_key
        pkey = Sentry::AsymmetricSentry.decrypt_private_key(self.crypted_private_key, self.old_password)
        self.crypted_private_key = Sentry::SymmetricSentry.encrypt_to_base64(pkey.to_s, self.password)        
      end

    end
  end
end

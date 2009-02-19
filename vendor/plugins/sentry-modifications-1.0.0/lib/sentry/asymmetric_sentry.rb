module Sentry
  class AsymmetricSentry
    
    # Returns a hash containing public and private keys. 
    # Private key will be encrypted with the given password.
    def self.generate_random_rsa_key(password, options={})
      rsa = OpenSSL::PKey::RSA.new(512)
      public_key  = rsa.public_key.to_s
      private_key = SymmetricSentry.new(:algorithm => options[:symmetric_algorithm]).encrypt_to_base64(rsa.to_s, password)
      {:public => public_key, :private => private_key}
    end
    
    # Encrypt the given data with the given public key.
    def self.encrypt_to_base64_with_key(data, key)
      encrypted = OpenSSL::PKey::RSA.new(key).public_encrypt(data)
      Base64.encode64(encrypted)
    end
    
    # Decrypt the given base64-encoded data.
    # Expects a symetrically-encrypted private key with password.
    def self.decrypt_from_base64_with_key(data, encrypted_key, password)
      decoded     = Base64.decode64(data)
      private_key = decrypt_private_key(encrypted_key, password)
      OpenSSL::PKey::RSA.new(private_key).private_decrypt(decoded)
    end
    
    def self.decrypt_private_key(encrypted_key, password)
      encryptor   = SymmetricSentry.new
      private_key = encryptor.decrypt_from_base64(encrypted_key, password)
    end
    
  end
end
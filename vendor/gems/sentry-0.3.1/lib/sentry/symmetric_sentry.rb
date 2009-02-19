module Sentry
  class SymmetricSentry
    @@default_algorithm = 'DES-EDE3-CBC'
    @@default_key = nil
    attr_accessor :algorithm
    def initialize(options = {})
      @algorithm = options[:algorithm] || @@default_algorithm
    end
  
    def encrypt(data, key = nil)
      key = check_for_key!(key)
      des = encryptor
      des.encrypt(key)
      data = des.update(data)
      data << des.final
    end
  
    def encrypt_to_base64(text, key = nil)
      Base64.encode64(encrypt(text, key))
    end
  
    def decrypt(data, key = nil)
      key = check_for_key!(key)
      des = encryptor
      des.decrypt(key)
      text = des.update(data)
      text << des.final
    end
  
    def decrypt_from_base64(text, key = nil)
      decrypt(Base64.decode64(text), key)
    end

    class << self
      def default_algorithm
        @@default_algorithm
      end
    
      def default_algorithm=(value)
        @@default_algorithm = value
      end
      
      def default_key
        @@default_key
      end
      
      def default_key=(value)
        @@default_key = value
      end

      def encrypt(data, key = nil)
        self.new.encrypt(data, key)
      end
  
      def encrypt_to_base64(text, key = nil)
        self.new.encrypt_to_base64(text, key)
      end
  
      def decrypt(data, key = nil)
        self.new.decrypt(data, key)
      end
  
      def decrypt_from_base64(text, key = nil)
        self.new.decrypt_from_base64(text, key)
      end
    end

    private
    def encryptor
      @encryptor ||= OpenSSL::Cipher::Cipher.new(@algorithm)
    end
    
    def check_for_key!(key)
      valid_key = key || @@default_key
      raise Sentry::NoKeyError if valid_key.nil?
      valid_key
    end
  end
end
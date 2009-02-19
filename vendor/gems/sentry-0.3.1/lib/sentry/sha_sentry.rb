require 'digest/sha1'
module Sentry
  class ShaSentry
    @@salt = 'salt'
    attr_accessor :salt
    
    # Encrypts data using SHA.
    def encrypt(data)
      self.class.encrypt(data + salt.to_s)
    end
    
    # Initialize the class.  
    # Used by ActiveRecord::Base#generates_crypted to set up as a callback object for a model
    def initialize(attribute = nil)
      @attribute = attribute
    end
    
    # Performs encryption on before_validation Active Record callback
    def before_validation(model)
      return unless model.send(@attribute)
      model.send("crypted_#{@attribute}=", encrypt(model.send(@attribute)))
    end
        
    class << self
      # Gets the class salt value used when encrypting
      def salt
        @@salt
      end
      
      # Sets the class salt value used when encrypting
      def salt=(value)
        @@salt = value
      end
      
      # Encrypts the data
      def encrypt(data)
        Digest::SHA1.hexdigest(data + @@salt)
      end
    end
  end
end
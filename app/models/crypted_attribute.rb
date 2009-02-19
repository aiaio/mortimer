class CryptedAttribute < ActiveRecord::Base

  # Belongs to whichever class has the encrypted attributes.
  belongs_to :encryptable, :polymorphic => true

  named_scope :for_encrypter, lambda {|encrypter| 
    { :conditions => {:encrypter_id => encrypter.id} }
  }

  named_scope :for_encryptable, lambda {|encryptable| 
    { :conditions => {:encryptable_id => encryptable.id, :encryptable_type => encryptable.class.to_s} }
  }

  # Defines a setter method for classes using the attribute.
  def setter
    self.class.to_s.sub("CryptedAttribute", "").underscore + "="
  end  

end


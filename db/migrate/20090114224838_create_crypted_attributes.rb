class CreateCryptedAttributes < ActiveRecord::Migration
  def self.up
    create_table :crypted_attributes do |t|
      # Contains the encrypted attribute.
      t.column :data,           :string

      # Model to which encrypted attribute is assigned.
      t.column :encryptable_id,      :integer
      t.column :encryptable_type,    :string

      # Model containing public/private keys.
      # This is almost always the User model.
      t.column :encrypter_id,   :integer

      # Type for subclassing.  Each subclass will
      # represent a different encrypted attribute.
      t.column :type,           :string
      t.timestamps
    end
  end

  def self.down
    drop_table :crypted_attributes
  end
end

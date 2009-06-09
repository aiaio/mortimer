class ChangeEncryptedKeyToTextField < ActiveRecord::Migration
  def self.up
    change_column :crypted_attributes, :data, :text
  end

  def self.down
    change_column :crypted_attributes, :data, :string
  end
end

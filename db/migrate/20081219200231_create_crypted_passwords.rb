class CreateCryptedPasswords < ActiveRecord::Migration
  def self.up
    create_table :crypted_passwords do |t|
      t.column :data,         :text
      
      t.column :entry_id,     :integer
      t.column :user_id,      :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :crypted_passwords
  end
end

class DropCryptedPasswords < ActiveRecord::Migration
  def self.up
    drop_table :crypted_passwords
  end

  def self.down
    create_table :crypted_passwords do |t|
      t.column :data,         :text
      
      t.column :entry_id,     :integer
      t.column :user_id,      :integer
      t.timestamps
    end  
  end
end

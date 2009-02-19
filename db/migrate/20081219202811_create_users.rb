class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string, :limit => 40
      t.column :first_name,                :string, :limit => 100, :default => ''
      t.column :last_name,                 :string, :limit => 100, :default => ''
      t.column :email,                     :string, :limit => 100
      
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :state,                     :string
      
      t.column :deleted_at,                :datetime
      
      t.column :public_key,                :text
      t.column :crypted_private_key,       :text
      
      t.column :is_admin,                  :boolean, :default => false
    end
    
    add_index :users, :login, :unique => true
    
  end

  def self.down
    drop_table "users"
  end
end

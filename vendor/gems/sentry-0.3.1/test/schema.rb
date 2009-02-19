ActiveRecord::Schema.define(:version => 1) do

  create_table "users", :force => true do |t|
    t.column :crypted_password,   :string, :limit => 255
    t.column :crypted_creditcard, :string, :limit => 255
    t.column :login,              :string, :limit => 50
    t.column :type,               :string, :limit => 20
  end

end
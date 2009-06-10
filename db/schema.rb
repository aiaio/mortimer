# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090608205158) do

  create_table "crypted_attributes", :force => true do |t|
    t.text     "data"
    t.integer  "encryptable_id"
    t.string   "encryptable_type"
    t.integer  "encrypter_id"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entries", :force => true do |t|
    t.string   "title"
    t.text     "notes"
    t.integer  "group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "permissions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "admin_user_id"
    t.string   "mode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",               :limit => 40
    t.string   "first_name",          :limit => 100, :default => ""
    t.string   "last_name",           :limit => 100, :default => ""
    t.string   "email",               :limit => 100
    t.string   "crypted_password",    :limit => 40
    t.string   "salt",                :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.text     "public_key"
    t.text     "crypted_private_key"
    t.boolean  "is_admin",                           :default => false
    t.boolean  "is_root",                            :default => false
  end

  add_index "users", ["login"], :name => "index_users_on_login", :unique => true

end

class AddIsRootToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :is_root, :boolean, :default => false
  end

  def self.down
    remove_column :users, :is_root
  end
end

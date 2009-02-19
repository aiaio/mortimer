class RemoveDeletedAtFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :deleted_at
  end

  def self.down
    add_column :users, :deleted_at, :datetime
  end
end

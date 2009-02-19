class AddParentIdToGroups < ActiveRecord::Migration
  def self.up
    remove_column :groups, :parent_id
    add_column    :groups, :parent_id, :integer
  end

  def self.down
    remove_column :groups, :parent_id
    add_column    :groups, :parent_id, :string
  end
end

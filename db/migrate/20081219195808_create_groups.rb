class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.column :title, :string
      
      t.column :parent_id, :string      
      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end

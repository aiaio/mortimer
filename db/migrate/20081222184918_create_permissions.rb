class CreatePermissions < ActiveRecord::Migration
  def self.up
    create_table :permissions do |t|
      t.column :user_id,       :integer
      t.column :group_id,      :integer
      t.column :admin_user_id, :integer
      
      # Modes will be "admin" and "read."
      t.column :mode,     :string

      t.timestamps
    end
  end

  def self.down
    drop_table :permissions
  end
end

class CreateEntries < ActiveRecord::Migration
  def self.up
    create_table :entries do |t|
      t.column :title,      :string
      
      t.column :username,  :string
      t.column :url,       :string
      t.column :notes,     :text
      
      t.column :group_id,  :integer
      
      t.timestamps
    end
  end

  def self.down
    drop_table :entries
  end
end

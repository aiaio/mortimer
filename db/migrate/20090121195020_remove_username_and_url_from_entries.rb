class RemoveUsernameAndUrlFromEntries < ActiveRecord::Migration
  def self.up
    remove_column :entries, :username
    remove_column :entries, :url
  end

  def self.down
    add_column :entries, :url, :string
    add_column :entries, :username, :string
  end
end

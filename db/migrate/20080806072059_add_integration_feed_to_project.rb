class AddIntegrationFeedToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :ci_feed, :string
    add_column :projects, :ci_keyword, :string
    add_column :projects, :ci_desc, :integer        
  end

  def self.down
    remove_column :projects, :ci_feed
    remove_column :projects, :ci_keyword
    remove_column :projects, :ci_desc        
  end
end

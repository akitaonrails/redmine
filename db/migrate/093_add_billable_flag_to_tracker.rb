class AddBillableFlagToTracker < ActiveRecord::Migration
  def self.up
    add_column :trackers, :is_billable, :boolean, :default => false
  end

  def self.down
    remove_column :trackers, :is_billable
  end
end

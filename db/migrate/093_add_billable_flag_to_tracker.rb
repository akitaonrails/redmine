class AddBillableFlagToTracker < ActiveRecord::Migration
  def self.up
    add_column :trackers, :task_code, :string, :limit => 30
  end

  def self.down
    remove_column :trackers, :task_code
  end
end

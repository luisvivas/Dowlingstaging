class AddScheduleToLabourLineItem < ActiveRecord::Migration
  def self.up
    add_column :labour_line_items, :scheduled, :boolean
  end

  def self.down
    remove_column :labour_line_items, :scheduled
  end
end

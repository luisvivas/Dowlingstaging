class AddDescriptionToTimeReports < ActiveRecord::Migration
  def self.up
    add_column :time_reports, :description, :text
    add_column :labour_line_items, :shop, :boolean, :default => true
    LabourLineItem.update_all(:shop => true)
  end

  def self.down
    remove_column :time_reports, :description
    remove_column :labour_line_items, :shop
  end
end

class AddCompleteToLabourLineItem < ActiveRecord::Migration
  def self.up
    add_column :labour_line_items, :complete, :boolean, :default => false
  end

  def self.down
    remove_column :labour_line_items, :complete
  end
end

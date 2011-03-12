class AddProgressToLineItems < ActiveRecord::Migration
  def self.up
    add_column :product_line_items, :product_consumed, :decimal
    add_column :labour_line_items, :hours_completed, :decimal
  end

  def self.down
    remove_column :labour_line_items, :hours_completed
    remove_column :product_line_items, :product_consumed
  end
end

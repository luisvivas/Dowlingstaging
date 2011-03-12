class AddCostPerPoundToProductLineItems < ActiveRecord::Migration
  def self.up
    add_column :product_line_items, :cost_per_pound, :decimal
  end

  def self.down
    remove_column :product_line_items, :cost_per_pound
  end
end

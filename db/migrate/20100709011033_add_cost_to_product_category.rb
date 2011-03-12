class AddCostToProductCategory < ActiveRecord::Migration
  def self.up
    add_column :product_categories, :cost_per_pound, :decimal
  end

  def self.down
    remove_column :product_categories, :cost_per_pound
  end
end

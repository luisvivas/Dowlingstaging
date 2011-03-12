class AlterDimensionOnProductLineItem < ActiveRecord::Migration
  def self.up
    change_column :product_line_items, :dimension, :string
  end

  def self.down
    change_column :product_line_items, :dimension, :decimal
  end
end

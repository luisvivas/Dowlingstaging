class AddOrderedToProductLineItem < ActiveRecord::Migration
  def self.up
    add_column :product_line_items, :ordered, :boolean, :default => false
    add_column :product_line_items, :in_stock, :boolean, :default => false
  end

  def self.down
    remove_column :product_line_items, :ordered
    remove_column :product_line_items, :in_stock
  end
end

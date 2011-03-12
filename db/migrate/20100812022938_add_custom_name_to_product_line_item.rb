class AddCustomNameToProductLineItem < ActiveRecord::Migration
  def self.up
    add_column :product_line_items, :custom_name, :string
    add_column :product_line_items, :type, :string
    rename_table :product_line_items, :product_based_line_items
    ProductBasedLineItem.update_all :type => "ProductLineItem"
  end

  def self.down
    remove_column :product_based_line_items, :custom_name
    remove_column :product_based_line_items, :type
    rename_table :product_based_line_items, :product_line_items
  end
end

class AddMarkupToLineItems < ActiveRecord::Migration
  def self.up
    add_column :product_line_items, :markup, :decimal
    add_column :labour_line_items, :markup, :decimal
    add_column :quote_items, :hardware_markup, :decimal
    add_column :quote_items, :markup, :decimal
    
  end

  def self.down
    remove_column :product_line_items, :markup
    remove_column :labour_line_items, :markup
    remove_column :quote_items, :markup
    
  end
end

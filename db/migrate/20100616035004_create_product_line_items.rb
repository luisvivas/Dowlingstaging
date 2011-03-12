class CreateProductLineItems < ActiveRecord::Migration
  def self.up
    create_table :product_line_items do |t|
      t.integer :product_id
      t.integer :quote_item_id
      t.integer :product_size_id
      t.decimal :amount_needed
      t.decimal :dimension
      t.decimal :order_quantity
      t.timestamps
    end
  end

  def self.down
    drop_table :product_line_items
  end
end

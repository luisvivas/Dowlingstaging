class CreateProductSizes < ActiveRecord::Migration
  def self.up
    create_table :product_sizes do |t|
      t.string :name
      t.integer :product_id
      t.decimal :retail_price
      t.decimal :cost

      t.timestamps
    end
  end

  def self.down
    drop_table :product_sizes
  end
end

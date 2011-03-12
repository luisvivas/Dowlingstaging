class CreateProductCategories < ActiveRecord::Migration
  def self.up
    create_table :product_categories do |t|
      t.string :name
      t.integer :parent_id, :children_count, :ancestors_count, :descendants_count
      t.boolean :hidden
      
      t.timestamps
    end
  end

  def self.down
    drop_table :product_categories
  end
end

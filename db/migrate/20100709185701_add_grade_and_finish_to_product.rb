class AddGradeAndFinishToProduct < ActiveRecord::Migration
  def self.up    
    add_column :products, :grade, :boolean
    add_column :products, :finish, :boolean
    add_column :product_line_items, :grade, :string
    add_column :product_line_items, :finish, :string
  end

  def self.down    
    [:products, :product_line_items].each do |tab|
      remove_column tab, :finish
      remove_column tab, :grade
    end
  end
end

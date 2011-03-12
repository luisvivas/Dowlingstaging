class ChangeProductSize < ActiveRecord::Migration
  def self.up
    remove_column :product_sizes, :cost
    add_column :product_sizes, :amount, :decimal
  end

  def self.down
    add_column :product_sizes, :cost, :decimal
    remove_column :product_sizes, :amount
  end
end

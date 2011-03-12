class AddTaxToQuote < ActiveRecord::Migration
  def self.up
    add_column :quotes, :tax, :decimal
  end

  def self.down
    remove_column :quotes, :tax
  end
end

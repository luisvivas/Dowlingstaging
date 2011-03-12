class RenameQuoteTaxToMarkup < ActiveRecord::Migration
  def self.up
    add_column :quotes, :markup, :decimal    
    remove_column :quotes, :tax
    Quote.update_all(:markup => Settings.quote_markup)
  end

  def self.down
    add_column :quotes, :tax, :decimal    
    remove_column :quotes, :markup
  end
end

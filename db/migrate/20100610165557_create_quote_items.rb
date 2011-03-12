class CreateQuoteItems < ActiveRecord::Migration
  def self.up
    create_table :quote_items do |t|
      t.integer :quote_id
      t.string :name
      t.text :notes
      
      t.timestamps
    end
  end

  def self.down
    drop_table :quote_items
  end
end

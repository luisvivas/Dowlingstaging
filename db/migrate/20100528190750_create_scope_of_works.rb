class CreateScopeOfWorks < ActiveRecord::Migration
  def self.up
    create_table :scope_of_works do |t|
      t.integer :contact_id
      t.integer :request_for_quote_id
      t.integer :quote_id
      t.text :notes
      
      t.timestamps
    end
  end

  def self.down
    drop_table :scope_of_works
  end
end

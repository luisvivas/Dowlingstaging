class RemoveQuoteIdFromScopeOfWork < ActiveRecord::Migration
  def self.up
    remove_column :scope_of_works, :quote_id
  end

  def self.down
    add_column :scope_of_works, :quote_id, :integer
  end
end

class AddNotesToScopeItem < ActiveRecord::Migration
  def self.up
    add_column :scope_items, :notes, :text
  end

  def self.down
    remove_column :scope_items, :notes
  end
end

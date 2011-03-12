class AddCompleteToRequestForQuotes < ActiveRecord::Migration
  def self.up
    add_column :request_for_quotes, :complete, :boolean
  end

  def self.down
    remove_column :request_for_quotes, :complete
  end
end

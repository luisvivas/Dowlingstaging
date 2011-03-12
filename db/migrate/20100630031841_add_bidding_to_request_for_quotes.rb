class AddBiddingToRequestForQuotes < ActiveRecord::Migration
  def self.up
    add_column :request_for_quotes, :bidding, :boolean
  end

  def self.down
    remove_column :request_for_quotes, :bidding
  end
end

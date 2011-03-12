class AddBidderToBusiness < ActiveRecord::Migration
  def self.up
    add_column :businesses, :bidder, :boolean, :default => false
  end

  def self.down
    remove_column :businesses, :bidder
  end
end

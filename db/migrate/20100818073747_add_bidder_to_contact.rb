class AddBidderToContact < ActiveRecord::Migration
  def self.up
    add_column :contacts, :bidder, :boolean, :default => false
  end

  def self.down
    remove_column :contacts, :bidder
  end
end

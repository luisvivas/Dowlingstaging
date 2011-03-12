class ChangeQuotePrintedAtToTimestamp < ActiveRecord::Migration
  def self.up
    remove_column :quotes, :printed_at
    add_column :quotes, :printed_at, :timestamp
  end

  def self.down
    change_column :quotes, :printed_at, :time
  end
end

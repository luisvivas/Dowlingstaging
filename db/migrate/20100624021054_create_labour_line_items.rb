class CreateLabourLineItems < ActiveRecord::Migration
  def self.up
    create_table :labour_line_items do |t|
      t.string  :description
      t.integer :workers
      t.integer :quote_item_id
      t.decimal :setup_time
      t.decimal :run_time
      t.decimal :hourly_rate

      t.timestamps
    end
  end

  def self.down
    drop_table :labour_line_items
  end
end

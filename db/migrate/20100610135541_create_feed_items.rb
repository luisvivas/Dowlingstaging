class CreateFeedItems < ActiveRecord::Migration
  def self.up
    create_table :feed_items do |t|
      t.integer :user_id
      t.integer :resource_id
      t.string :resource_type
      t.string :activity_type
      t.string :extra
      t.boolean :feed_display
      
      t.timestamps
    end
  end

  def self.down
    drop_table :feed_items
  end
end

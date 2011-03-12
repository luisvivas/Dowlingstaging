class CreateTimeReports < ActiveRecord::Migration
  def self.up
    create_table :time_reports do |t|
      t.integer :user_id
      t.integer :labour_line_item_id
      t.integer :end_of_day_report_id
      t.decimal :hours_added
      t.timestamps
    end
  end

  def self.down
    drop_table :time_reports
  end
end

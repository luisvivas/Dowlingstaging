class CreateEndOfDayReports < ActiveRecord::Migration
  def self.up
    create_table :end_of_day_reports do |t|
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :end_of_day_reports
  end
end

class AddExtraHoursToEndOfDayReport < ActiveRecord::Migration
  def self.up
    add_column :end_of_day_reports, :extra_hours, :decimal, :default => 0.0
  end

  def self.down
    remove_column :end_of_day_reports, :extra_hours
  end
end

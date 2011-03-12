class AddHoursDescriptionToEndOfDayReports < ActiveRecord::Migration
  def self.up
    add_column :end_of_day_reports, :hours_description, :text
  end

  def self.down
    remove_column :end_of_day_reports, :hours_description
  end
end

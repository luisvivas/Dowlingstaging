class TimeReport < ActiveRecord::Base
  belongs_to :user
  belongs_to :labour_line_item
  belongs_to :end_of_day_report
  
  validates_presence_of :hours_added, :user_id, :labour_line_item_id

  after_save :apply_delta
  private
    def apply_delta
      if self.labour_line_item.present? && self.hours_added_changed?
        self.labour_line_item.hours_completed += self.hours_added 
        self.labour_line_item.save
      end
    end
end

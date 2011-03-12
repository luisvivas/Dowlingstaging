class LabourLineItem < ActiveRecord::Base
  has_many :time_reports
  accepts_nested_attributes_for :time_reports
  
  thwart_access
  include KCPMS::Markupable
  belongs_to :quote_item
  validates_presence_of :markup, :hourly_rate, :workers, :setup_time, :run_time
#  validates_inclusion_of :shop, :in => [:true, :false, "true", "false"]
  validates_numericality_of :markup, :hourly_rate, :workers, :setup_time, :run_time

  def shop_text
    if self.shop 
      "Shop"
    else
      "Field"
    end
  end
  
  def work_order
    self.quote_item.quote.work_order
  end
  
  # def shop=(val)
  #   if val == "false"
  #     super(false)
  #   else
  #     super(val)
  #   end
  # end
  
  def scheduled
    return true if self.complete
    return self.read_attribute(:scheduled)
  end
  
  def hours_completed
    self.read_attribute(:hours_completed) || 0.0
  end
  def minutes_completed
    self.hours_completed * 60.0
  end
  def total_minutes
    self.workers * self.run_time + self.setup_time
  end
  def total_hours
    self.total_minutes / 60.0
  end
  def marked_up_hourly_rate
    self.markup_multiplier * self.hourly_rate
  end
  def subtotal
     self.total_hours * self.hourly_rate
  end
  def total
    self.subtotal * self.markup_multiplier
  end
  def slug
    key = self.quote_item_id.to_s.intern
  end
  def internal_total_cost
    self.hours_completed * self.hourly_rate
  end
  def profit
    self.total - self.internal_total_cost
  end
end

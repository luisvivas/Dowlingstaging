class EndOfDayReport < ActiveRecord::Base
  thwart_access

  attr_accessor :sign_out_after

  has_and_belongs_to_many :quote_items
  accepts_nested_attributes_for :quote_items
  belongs_to :user
  has_many :time_reports

  validates_presence_of :user_id, :extra_hours
  before_save :apply_time_reports
  after_save :reference_time_reports
  
  def self.aggregate_in_range(user_id, start, finish)
    reports = EndOfDayReport.includes(:time_reports => {:labour_line_item => {:quote_item => {:quote => :work_order}}}).where(:user_id => user_id, :created_at => start..finish)
    
    reports.inject({}) do |acc, eod|
      acc[eod.created_at.to_date] ||= {}
      ar = acc[eod.created_at.to_date]
      ar[:work_orders]  ||= {}
      ar[:reports]      ||= []
      ar[:sum]          ||= 0.0
      
      ar[:sum] += (eod.extra_hours || 0)
      ar[:reports] << eod
      
      eod.time_reports.reject {|r| r.hours_added == 0}.each do |report|
        ar[:sum] += (report.hours_added || 0)

        qi = report.labour_line_item.quote_item
        wo = qi.quote.work_order
        ar[:work_orders][wo.number] ||= {}
        ar[:work_orders][wo.number][qi.name] ||= []
        ar[:work_orders][wo.number][qi.name] << report
      end
      acc
    end
  end
  
  private
    def unset_time_reports
      self.quote_items.collect {|x| x.labour_line_items }.flatten.collect {|x| x.time_reports }.flatten.reject {|x| x.end_of_day_report.present? }
    end
    
    def apply_time_reports
      # unset_time_reports.each do |x|
      #   x.end_of_day_report = self
      #   if x.hours_added == 0.0
      #     x.destroy
      #   else
      #     x.labour_line_item.hours_completed += x.hours_added
      #   end
      #   x.save
      #   x.labour_line_item.save
      # end
      # true
    end
    
    def reference_time_reports
      # all_time_reports.each do |x|
      #   x.end_of_day_report = self
      #   x.save!
      # end
    end
end

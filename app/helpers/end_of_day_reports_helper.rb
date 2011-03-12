module EndOfDayReportsHelper
  def product_remaining(pli)
    v = (pli.order_quantity || 0) - (pli.product_consumed || 0)
    v < 0 ? 0 : v.to_f.round(2)
  end
  
  def labour_remaining(lli)
    v = (lli.total_hours || 0) - (lli.hours_completed || 0)
    v < 0 ? 0 : v.to_f.round(2)
  end
  
  def setup_time_report(lli)
    tr = lli.time_reports.build(:hours_added => 0, :user => current_user)
    tr
  end
end
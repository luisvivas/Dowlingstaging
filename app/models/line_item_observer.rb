class LineItemObserver < ActiveRecord::Observer
  observe :product_line_item, :labour_line_item, :custom_line_item, :quote_item

  def after_save(thing)
    if thing.is_a?(LabourLineItem) && thing.changed.reject{|x| x == "hours_completed" || x == "updated_at"}.empty?
      return true
    end
    if thing.respond_to?(:work_order)
      wo = thing.work_order
    elsif thing.respond_to?(:quote_item)
      wo = thing.quote_item.quote.work_order
    else
      return true
    end
    if wo.present?
      wo = wo.reload
      wo.set_completeness!
      wo.save if wo.changed?
    end
    true
  end
end

class RequestForQuoteQueueObserver < ActiveRecord::Observer
  observe :quote, :scope_of_work, :scope_item

  def get_rfq_from(object)
    rfq = object if object.is_a?(RequestForQuote)
    rfq ||= object.request_for_quote if object.respond_to?(:request_for_quote)
    rfq ||= object.scope_of_work.request_for_quote if object.respond_to?(:scope_of_work) && object.scope_of_work.present?
    rfq
  end
  
  def update_rfq(rfq)
    rfq = rfq.reload
    rfq.set_completeness!
    rfq.save if rfq.changed?
  end
  
  def after_save(object)
    rfq = self.get_rfq_from(object)
    update_rfq(rfq) if rfq
    true
  end
  
  def after_destroy(object)
    rfq = self.get_rfq_from(object)
    update_rfq(rfq) if rfq && rfq != object # ensure RFQ isnt the object being destroyed
    true
  end
end

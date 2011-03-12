class ScopeOfWork < ActiveRecord::Base
  thwart_access
  belongs_to :contact
  belongs_to :business
  belongs_to :request_for_quote
  validates_presence_of :request_for_quote_id, :bidder
  validate do
    errors.add_to_base("A contact or business bidder must be specified for this scope of work.") if self.contact.blank? && self.business.blank?
  end
  has_many :scope_items, :dependent => :destroy, :autosave => true
  has_many :quotes

  accepts_nested_attributes_for :scope_items, :allow_destroy => true

  def bidder
    self.contact || self.business
  end

  def validate_on_create
    unless (self.request_for_quote.scope_of_works.detect {|s| s.bidder == self.bidder }).nil?
      errors.add("bidder", "cannot be the same as another scope for the same RFQ. The referenced RFQ already has a scope of work for this bidder.")
    end
  end

  def duplicate
    s = self.clone
    s.scope_items << self.scope_items.collect { |si| si.duplicate }
    s
  end

  def to_quote(user)
    q = self.quotes.build do |q|
      q.job_name = self.request_for_quote.job_name
      q.contact = self.contact
      q.business = self.business
      q.shred = self.request_for_quote.shred
      q.needs_installation = false
      q.notes = self.notes
      q.category = self.request_for_quote.category
      q.markup = Settings.quote_markup
      q.user = user
      self.scope_items.each do |i|
        q.quote_items << i.to_quote_item
      end
    end
  end
end

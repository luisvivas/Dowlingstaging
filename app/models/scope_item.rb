class ScopeItem < ActiveRecord::Base
  thwart_access
  belongs_to :scope_of_work
  validates_presence_of :name

  def to_quote_item
    QuoteItem.new do |q|
      q.name = self.name
      q.notes = self.notes
      q.markup = Settings.quote_item_markup
      q.hardware_markup = Settings.quote_item_hardware_markup
    end
  end

  def duplicate
    self.clone
  end
end

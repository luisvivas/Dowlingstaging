class ProductSize < ActiveRecord::Base
  thwart_access
  belongs_to :product
  has_many :product_line_items
  validates_presence_of :name, :amount
  validates_numericality_of :amount  
  before_destroy :ensure_no_product_sizes
  def cost
    self.amount * 20
  end
  def referencing_quote_items
    self.product_line_items.map {|p| "#{p.quote_item.name} - #{p.quote_item.quote.number}" }
  end
  
  def destroyable?
    self.product_line_items.length == 0
  end
  
  private

  def ensure_no_product_sizes
    errors.add(:base, "Can't destroy Product Size #{self.name} since it is referenced by product line item(s) (referenced by #{self.referencing_quote_items.to_sentence})") if self.product_line_items.length > 0
  end
end

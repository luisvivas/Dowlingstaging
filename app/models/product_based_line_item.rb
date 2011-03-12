class ProductBasedLineItem < ActiveRecord::Base
  include KCPMS::Markupable
  belongs_to :quote_item
  validates_numericality_of :order_quantity, :markup

  def product_consumed 
    read_attribute(:product_consumed) || 0
  end
  
  def marked_up_cost_per_pound
    self.markup_multiplier * self.cost_per_pound
  end
  def marked_up_cost_per_piece
    self.markup_multiplier * self.cost_per_piece
  end
  def transit_state
    return "In Stock" if self.in_stock
    return "In Transit" if self.ordered
    "Unordered"
  end
  def total
    self.subtotal * self.markup_multiplier
  end
  
  def internal_total_cost
    [self.product_consumed, self.order_quantity].max * self.cost_per_piece
  end
  
  def profit
    self.total - self.internal_total_cost
  end
end
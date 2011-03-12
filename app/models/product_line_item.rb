class ProductLineItem < ProductBasedLineItem
  thwart_access
  belongs_to :quote_item
  belongs_to :product
  belongs_to :product_size
  validates_presence_of :product_id, :product_size_id, :dimension
  validates_numericality_of :amount_needed, :product_consumed
  
  scope :unordered, scoped.joins(:quote_item => {:quote => :work_order}).where("ordered = ? OR in_stock = ?", false, false).includes({:product => :category}, :product_size)
  
  def self.unordered_aggregate
    plis = self.unordered
    plis.inject({}) do |agg, pli|
      key = pli.slug
      if(agg[key].present?)
        agg[key][:order_quantity] += pli.order_quantity
        agg[key][:line_items] << pli
      else
        agg[key] = pli.attributes.merge({:product_size => pli.product_size, :product => pli.product}).with_indifferent_access
        agg[key][:line_items] = [pli]
      end
      agg
    end
  end
  
  def dimension_decimal
    self.product.class.dimension_decimal(self.dimension) if self.product.present?
  end
  
  def calculated_order_quantity
    return self.amount_needed / self.dimension_decimal if self.dimension_decimal > 0
    return 0
  end
  
  def total_weight
    # Weight per ft             ft per piece              pieces
    self.product_size.amount * self.dimension_decimal * self.order_quantity
  end
  def cost_per_unit
    self.cost_per_pound * self.product_size.amount # unit weight
  end
  def cost_per_piece
    self.cost_per_unit * self.dimension_decimal
  end
  def subtotal
    self.cost_per_piece * self.order_quantity
  end

  def slug
    key = "#{self.product_id.to_s}_#{self.product_size_id.to_s}"
    key += "_" + self.grade if self.grade.present?
    key += "_" + self.finish if self.finish.present?
    key.intern
  end
end

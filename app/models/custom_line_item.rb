class CustomLineItem < ProductBasedLineItem
  def cost_per_piece
    self.cost_per_pound
  end
  # Cost per piece is stored in the cost per pound column in the DB
  def subtotal
    self.cost_per_pound * self.order_quantity
  end
  def slug
    self.custom_name.parameterize
  end
end
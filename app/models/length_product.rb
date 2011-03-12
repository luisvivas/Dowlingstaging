class LengthProduct < Product
  thwart_access do
    name :product
  end
  
  def self.raw_available_dimensions
    Settings.length_product_dimensions
  end
  def self.dimension_decimal(d)
    d.to_i
  end
end
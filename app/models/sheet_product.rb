class SheetProduct < Product
  thwart_access do
    name :product
  end
  
  def self.raw_available_dimensions
    Settings.sheet_product_dimensions
  end
  
  def self.dimension_decimal(d)
    strs = d.split('x', 2).map {|s| s.gsub(/[^0-9]/, "") }
    if strs.length == 2
      strs.first.to_i * strs.second.to_i
    else
      d.to_i || 1 # never return 0, divide by 0 errors all over the place!
    end
  end
end
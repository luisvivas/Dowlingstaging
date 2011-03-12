class UnitProduct < Product
  def self.raw_available_dimensions
    ["1"]
  end
  def self.dimension_decimal(d)
    1
  end
end
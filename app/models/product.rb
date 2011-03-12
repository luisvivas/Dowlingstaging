class Product < ActiveRecord::Base    
  thwart_access do
    name :product
  end
  has_many :sizes, :class_name => "ProductSize", :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :sizes, :allow_destroy => true
  
  belongs_to :category, :class_name => "ProductCategory"
  
  has_many :siblings_in_category, :through => :category, :source => :products, :uniq => true
  
  validates_presence_of :name, :category
  validates_inclusion_of :grade, :finish, :in => [true, false]
  validates_uniqueness_of :name
  
  class << self
    def available_kinds
      {"Area (sq ft)" => "SheetProduct", "Length (ft)" => "LengthProduct", "Discrete Unit" => "UnitProduct"}
    end
  
    def available_dimensions
      self.raw_available_dimensions.inject({}) {|acc, d| acc[d] = self.dimension_decimal(d); acc}
    end
  
    delegate :available_grades, :available_finishes, :to => 'Settings'
  end
  
  scope :with_sizes, includes(:sizes)  
  
  scope :grid_conditions, lambda { |grid, params|
    grid_scope = scoped.joins('LEFT JOIN (SELECT product_categories.id, (category_parents."name" || \' \' || product_categories.name) as "extended_name" FROM "product_categories" LEFT JOIN "product_categories" AS "category_parents" ON category_parents."id" = product_categories."parent_id") AS "full_product_categories" ON "products"."category_id" = "full_product_categories"."id"')
    case grid
    when :in_category
      grid_scope = grid_scope.where(:category_id => params[:product_category_id])
    end
    grid_scope
  }
  
  scope :find_for_grid, lambda { |grid, params| 
    grid_conditions(grid, params).joins(:category).includes({:category => :parent}).order("products.name")
  }
  
  scope :count_for_grid, lambda { |grid, params| 
    grid_conditions(grid, params)
  }
  
  initialize_grid = Proc.new do |grid|
    grid.column :name, :search_field => "products.name"
    grid.column :category, :search_field => "full_product_categories.extended_name", :proc => Proc.new {|product| product.category.name_with_parents }
#    grid.column :sizes, :proc => Proc.new{ |product| product.sizes.map{|size| size.name}.join(', ')}
  end

  gridify &initialize_grid
  gridify :in_category, &initialize_grid
  
  def init_sizes
    unless self.sizes.is_a?(Array) && self.sizes.length > 0
      self.sizes = [ProductSize.new]
    end
  end
  
  def name_with_categories      
    categories = self.category.ancestors << self.category
    "#{categories.map{|c| c.name}.join(' -> ')}: #{self.name}"
  end
  
  def kind
    self[:type]
  end
  
  def kind=(new_kind)
    self[:type] = new_kind
  end
end

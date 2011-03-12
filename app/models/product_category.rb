class ProductCategory < ActiveRecord::Base
  thwart_access    
  acts_as_category :order_by => "name"
  validates_presence_of :name
  has_many :products, :foreign_key => :category_id, :uniq => true
  before_destroy :ensure_no_children_categories
  before_destroy :ensure_no_member_products
  
  def name_with_parents
    if self.root?
      self.name
    else
      "#{self.ancestors.map{|c| c.name}.join(' -> ')} -> #{self.name}"
    end
  end
  
  def cost_per_pound
    return false unless self.root?
    read_attribute(:cost_per_pound)
  end
  
  def cost_per_pound=(cost)
    return false unless self.root?
    write_attribute(:cost_per_pound, cost)
  end
  
  private 
  
  def ensure_no_children_categories
    unless self.children.empty?
      errors.add(:the_category, "cannot have any children categories if it is going to be deleted. Please delete all children categories before deleting this one.")
      return false
    end
  end
  
  def ensure_no_member_products
    unless self.products.empty?
      errors.add(:the_category, "cannot have any member products if it is going to be deleted. Please delete all the member products before deleting this category.")
      return false
    end
  end
end

class QuoteItem < ActiveRecord::Base
  thwart_access
  include KCPMS::Markupable

  belongs_to :quote
  validates_presence_of :name, :hardware_markup, :markup
  
  has_many :product_line_items, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :product_line_items, :allow_destroy => true
  
  has_many :labour_line_items, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :labour_line_items, :allow_destroy => true
  
  has_many :custom_line_items, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :custom_line_items, :allow_destroy => true
  
  def hardware_markup_multiplier
    (self.hardware_markup / 100) + 1
  end
      
  def products_subtotal
    self.product_line_items.to_a.sum {|li| li.total }
  end
  def labour_subtotal
    self.labour_line_items.to_a.sum {|li| li.total }
  end
  def custom_subtotal
    self.custom_line_items.to_a.sum {|li| li.total }
  end
  
  def marked_up_products_subtotal
    self.products_subtotal * self.hardware_markup_multiplier * self.markup_multiplier * self.quote.markup_multiplier
  end
  
  def marked_up_labour_subtotal
    self.labour_subtotal * self.hardware_markup_multiplier * self.markup_multiplier * self.quote.markup_multiplier
  end
  
  def marked_up_custom_subtotal
    self.custom_subtotal * self.markup_multiplier * self.quote.markup_multiplier
  end
  
  def labour_complete?
    self.labour_line_items.all?(&:complete)
  end
  def total_minutes
    self.labour_line_items.to_a.sum {|li| li.total_minutes }
  end
  def total_hours
    self.total_minutes / 60
  end
  def total_hours_completed
    self.labour_line_items.to_a.sum {|li| li.hours_completed || 0 }
  end
  def total_minutes_completed
    self.total_hours_completed * 60
  end
  
  def subtotal
    self.products_subtotal + self.labour_subtotal + self.custom_subtotal
  end
  
  def total
    ((self.products_subtotal + self.labour_subtotal) * self.hardware_markup_multiplier + self.custom_subtotal) * self.markup_multiplier
  end
  
  def marked_up_total
    self.total * self.quote.markup_multiplier
  end
  def duplicate
    qi = self.clone
    [:product_line_items, :labour_line_items, :custom_line_items].each do |m|
      qi.send(m.to_s.+("=").to_sym, self.send(m).collect { |i| i.clone })
    end
    qi
  end
end

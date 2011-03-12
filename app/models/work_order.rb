class WorkOrder < ActiveRecord::Base
  thwart_access
  belongs_to :quote
  accepts_nested_attributes_for :quote

  validates_presence_of :quote_id, :due_date
  validate :quote_must_have_items, :quote_items_must_have_products
  
  delegate  :correspondence, :job_resources, :contact, :business, :contactable, :job_name, :quote_items, 
            :products_aggregate, :labour_aggregate, :custom_aggregate,
            :all_labour_items, :all_product_items, :all_custom_items,
            :total_minutes, :needs_installation, :notes, :to => :quote
  
  include Discussable
  discussed_using "WO"

	before_save :set_completeness!
	
  scope :active, scoped.where(:complete => false)
  scope :with_quote_details, scoped.includes(:quote => [
                                      {:quote_items => 
                                        [{:product_line_items => [:product, :product_size]}, 
                                          :labour_line_items,
                                          :custom_line_items
                                        ]
                                      },
                                      :contact
                                    ])
  scope :queue, scoped.active.with_quote_details.order(:due_date)

  scope :find_for_grid, lambda { |grid, params|
	  grid_scope = scoped.includes(:quote => [:contact, :business]).joins(:quote).joins('LEFT JOIN "businesses" ON "businesses"."id" = "quotes"."business_id"').joins('LEFT JOIN (SELECT *, (first_name || \' \' || last_name) AS full_name FROM "contacts") AS contacts ON "contacts"."id" = "quotes"."contact_id"').select("work_orders.*, contacts.full_name, businesses.name")
    grid_scope
	}

  scope :count_for_grid

	gridify do |grid|
	  grid.column :id, :search_field => "CAST(quotes.id as text)", :hidden => false, :proc => lambda {|record| record.number }
  	grid.column :quote, :search_field => "CAST(quotes.id as text)", :proc => lambda {|q| q.quote.number }
  	grid.column :contact_name, :search_field => "contacts.full_name", :proc => lambda {|record| record.contact.name if record.contact.present? }
    grid.column :business_name, :search_field => "businesses.name", :proc => lambda {|record| record.business.name if record.business.present? }
    
	end
	  
  def editable?
    ! self.po_number.present?
  end
  
  def name_with_number
    "#{self.number} - #{self.job_name}"
  end
  
  def name_with_number_and_contactable
    "#{self.name_with_number} for #{self.contactable}"
  end

  def number
    "WO##{self.quote.id.to_s.rjust(5, '0')}"
  end

	def overdue?
	  self.due_date < Time.now
	end

  def schedule
    @schedule ||= Schedule.new(self)
    @schedule
  end
    
  def unordered_something(what)
	  what.delete_if {|k,a| 
	    a[:line_items].all? {|pli| pli.ordered || pli.in_stock }
	  }
	end
	def in_transit_something(what) 
	  what.delete_if {|k,a| 
	    a[:line_items].all? {|pli| !pli.ordered || (pli.ordered && pli.in_stock)}
	  }
	end
	def unavailable_something(what)
    what.delete_if {|k,a| 
      a[:line_items].all? {|pli| pli.in_stock }
    }
  end
  
  [:products, :custom].each do |what|
    [:unordered, :in_transit, :unavailable].each do |status|
      define_method(("#{status}_#{what.to_s}").to_sym) do
        self.send("#{status}_something".to_sym, self.send(("#{what}_aggregate").to_sym))
      end
    end
  end
    
  def unscheduled_labour
    self.all_labour_items.delete_if(&:scheduled)
  end
  
  def incomplete_labour
    self.all_labour_items.delete_if(&:complete)
  end
  
  def products_ordered_status
    return BoxStates::Complete if self.products_aggregate.length == 0
    if self.unordered_products.length > 0 || self.unordered_custom.length > 0
      return BoxStates::Incomplete if self.unordered_products == self.products_aggregate
      return BoxStates::InProgress
    end
    BoxStates::Complete
  end
  
  def products_available_status
    return BoxStates::Complete if self.products_aggregate.length == 0
    return BoxStates::Incomplete if self.products_ordered_status < BoxStates::Complete
    return BoxStates::InProgress if self.unavailable_products.length > 0 || self.unavailable_custom.length > 0
    BoxStates::Complete
  end
  
  def labour_scheduling_status
    return BoxStates::Complete if self.all_labour_items.length == 0
    return BoxStates::Incomplete if self.unscheduled_labour == self.all_labour_items
    return BoxStates::InProgress if self.unscheduled_labour.length > 0
    BoxStates::Complete
  end
  
  def labour_status
    return BoxStates::Complete if self.all_labour_items.length == 0
    return BoxStates::Incomplete if self.incomplete_labour == self.all_labour_items
    return BoxStates::InProgress if self.incomplete_labour.length > 0
    BoxStates::Complete
  end
  
  def installation_status
    BoxStates::Complete
  end
  
  def po_status
    return BoxStates::Complete if self.po_number.present?
    BoxStates::Incomplete
  end
  
  def set_completeness!
    self.complete = [self.products_ordered_status, 
                      self.products_available_status, 
                      self.labour_scheduling_status,
                      self.labour_status, 
                      self.installation_status, 
                      self.po_status].all?(&:complete?)
    true
  end
  
  private

  def quote_must_have_items
    errors.add(:quote, "must have set quote items") if self.quote.present? and self.quote.quote_items.blank?
  end
  
  def quote_items_must_have_products
    errors.add(:quote, "items must have at least one product attached") if self.quote.present? and self.quote.quote_items.any? {|qi| qi.product_line_items.blank? }
  end
end

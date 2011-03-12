class RequestForQuote < ActiveRecord::Base
  thwart_access
  has_many :contacts, :as => :bidders, :through => :scope_of_works
  has_many :businesses, :through => :scope_of_works
  has_many :scope_of_works, :dependent => :destroy, :autosave => true
  has_many :job_resources, :as => :attachable
  
  include Discussable
  discussed_using "RFQ"

  before_save :set_completeness!
  validates_presence_of :job_name, :category
  validates_uniqueness_of :job_name
  accepts_nested_attributes_for :scope_of_works, :allow_destroy => true
  
  scope :find_for_grid, lambda { |grid, params| 
	  grid_scope = includes(:contacts, :businesses)
    grid_scope
	}
	
	scope :active, scoped.where(:complete => false, :bidding => true)
	scope :with_scope_details, scoped.includes(:scope_of_works => [:contact, :business, :scope_items, :quotes])
	scope :queue, scoped.with_scope_details.active.order(:due_date)

	gridify do |grid|
	  grid.column :id, :search_field => "CAST(request_for_quotes.id as text)", :label => "Number", :proc => lambda {|record| record.number }
		grid.column :bidders, :proc => lambda {|rfq| rfq.contacts.to_sentence }
	end
		
	def number
	  "RFQ##{self.id.to_s.rjust(5, '0')}"
	end

	def number_and_name
	  self.number + ": " + self.job_name
	end

  def unprinted_quotes
	  self.scope_of_works.collect{|s| s.quotes }.flatten.reject {|q| q.printed_at.present? && q.printed_at > Time.utc_time(2001, 1, 1, 0, 0, 0, 0)}
	end

  def quoteless_scopes
    self.scope_of_works.reject {|scope| scope.quotes.present? }
  end
  
  def itemless_scopes
    self.scope_of_works.reject {|scope| scope.scope_items.present? }
  end
  
  def bidders_added_status
    if(self.scope_of_works.blank?)
      BoxStates::Incomplete
    else
      BoxStates::Complete
    end
  end
  
	def scope_of_works_created_status
    return BoxStates::Incomplete if self.bidders_added_status < BoxStates::Complete
	  return BoxStates::InProgress if self.itemless_scopes.length > 0
	  BoxStates::Complete
	end
	
	def quotes_generated_status
    return BoxStates::Incomplete if self.bidders_added_status < BoxStates::Complete
	  return BoxStates::InProgress if self.quoteless_scopes.length > 0
	  BoxStates::Complete
	end
	
	def quotes_sent_status
    return BoxStates::Incomplete if self.bidders_added_status < BoxStates::Complete
    return BoxStates::InProgress if self.unprinted_quotes.length > 0 || quotes_generated_status < BoxStates::Complete
    BoxStates::Complete
	end
	
	def set_completeness!
    self.complete = [self.bidders_added_status,
                      self.scope_of_works_created_status,
                      self.quotes_generated_status,
                      self.quotes_sent_status].all?(&:complete?)
    true
  end
  
	def overdue?
	  self.due_date < Time.now
	end
end

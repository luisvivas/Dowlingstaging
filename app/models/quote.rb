class Quote < ActiveRecord::Base
  thwart_access
  has_many :quote_items, :dependent => :destroy, :autosave => true
  accepts_nested_attributes_for :quote_items, :allow_destroy => true
  has_many :job_resources, :as => :attachable
  has_one :work_order, :dependent => :destroy
  
  belongs_to :contact
  belongs_to :business
  belongs_to :scope_of_work
  belongs_to :user # creating user
  
  #validate :work_order_is_editable?
  before_save :set_rfq_completeness
  
  include Discussable
  discussed_using "Q"
  
  include KCPMS::Markupable

  validates_presence_of :job_name, :category, :markup, :user_id
  validate :contactable_present?
  scope :with_all_details, scoped.includes(
    {
      :quote_items => [{
        :product_line_items => [
          {:product => [
              {:category => :parent},
              :sizes,
              :siblings_in_category
          ]},
          :product_size
        ]
      },
        :labour_line_items,
        :custom_line_items
      ]
    },
    :contact,
    :business,
    :work_order)

  scope :find_for_grid, lambda { |grid, params|
    grid_scope = scoped.joins('LEFT JOIN "businesses" ON "quotes"."business_id" = "businesses"."id"').joins('LEFT JOIN (SELECT *, (first_name || \' \' || last_name) AS full_name FROM "contacts") AS contacts ON "contacts"."id" = "quotes"."contact_id"').select('quotes.*, businesses.name, contacts.full_name').includes(:business, :contact, :scope_of_work, :work_order)
    grid_scope
  }
  
  scope :count_for_grid
  
  gridify do |grid|
    grid.column :id, :search_field => "CAST(quotes.id as text)", :hidden => false, :proc => lambda {|record| record.number }
    grid.column :contact_name, :search_field => "contacts.full_name", :label => "Contact", :proc => lambda {|q| q.contact.name if q.contact.present? }
    grid.column :business_name, :search_field => "businesses.name", :label => "Business", :proc => lambda {|q| q.business.name if q.business.present? }
  end

  def number
    "Q##{self.id.to_s.rjust(5, '0')}"
  end

  def name_with_number
    "#{self.number} - #{self.job_name}"
  end

  def name_with_number_and_contactable
    "#{self.name_with_number} for #{self.contactable}"
  end

  def request_for_quote
    self.scope_of_work.request_for_quote if self.scope_of_work
  end

  def to_work_order
    WorkOrder.new do |wo|
      wo.id = self.id
      wo.quote = self
      wo.due_date = Time.now + 30.days
    end
  end

  def products_subtotal
    self.quote_items.to_a.sum {|i| i.products_subtotal}
  end

  def labour_subtotal
    self.quote_items.to_a.sum {|i| i.labour_subtotal}
  end

  def custom_subtotal
    self.quote_items.to_a.sum {|i| i.custom_subtotal}
  end

  def products_aggregate
    self.quote_items.inject({}.with_indifferent_access) do |agg, i|
      i.product_line_items.each do |pli|
        key = pli.slug
        if(agg[key].present?)
          [:internal_total_cost, :order_quantity, :amount_needed].each do |m|
            agg[key][m] += pli.send(m)
          end
          agg[key][:total_consumed] += pli.product_consumed
          agg[key][:internal_total_revenue] += pli.total
          agg[key][:line_items] << pli
        else
          agg[key] = pli.attributes.merge({:product_size => pli.product_size.attributes.with_indifferent_access, :product => pli.product.attributes.with_indifferent_access}).with_indifferent_access
          agg[key][:line_items] = [pli]
          agg[key][:total_consumed] = pli.product_consumed
          agg[key][:internal_total_cost] = pli.internal_total_cost
          agg[key][:internal_total_revenue] = pli.total
        end
      end
      agg
    end
  end

  def labour_aggregate
    self.quote_items.inject({}.with_indifferent_access) do |agg, i|
      i.labour_line_items.each do |lli|
        key = lli.slug
        if(agg[key].present?)
          agg[key][:internal_total_cost] += lli.internal_total_cost
          agg[key][:internal_total_revenue] += lli.total
          agg[key][:total] += lli.total_minutes
          agg[key][:total_worked] += lli.hours_completed
          agg[key][:max_workers] = [ lli.workers, agg[key][:max_workers] ].max
          agg[key][:line_items] << lli
          agg[key][:scheduled] = false unless lli.scheduled
          agg[key][:completed] = false unless lli.complete
        else
          agg[key] = lli.attributes.with_indifferent_access
          agg[key][:total] = lli.total_minutes
          agg[key][:total_worked] = lli.hours_completed
          agg[key][:max_workers] = lli.workers
          agg[key][:item] = i
          agg[key][:line_items] = [lli]
          agg[key][:scheduled] = lli.scheduled
          agg[key][:completed] = lli.complete
          agg[key][:internal_total_cost] = lli.internal_total_cost
          agg[key][:internal_total_revenue] = lli.total
        end
      end
      agg
    end
  end

  def custom_aggregate
    self.quote_items.inject({}.with_indifferent_access) do |agg, i|
      i.custom_line_items.each do |cli|
        key = cli.slug
        if(agg[key].present?)
          agg[key][:internal_total_cost] += cli.internal_total_cost
          agg[key][:internal_total_revenue] += cli.total
          agg[key][:order_quantity] += cli.order_quantity
          agg[key][:total_consumed] += cli.product_consumed
          agg[key][:line_items] << cli
        else
          agg[key] = cli.attributes.with_indifferent_access
          agg[key][:line_items] = [cli]
          agg[key][:total_consumed] = cli.product_consumed
          agg[key][:internal_total_cost] = cli.internal_total_cost
          agg[key][:internal_total_revenue] = cli.total
        end
      end
      agg
    end
  end

  def total
    self.subtotal * self.markup_multiplier
  end
  
  def contactable
    self.contact || self.business
  end

  def all_labour_items
    self.quote_items.inject([]) do |agg, i|
      agg + i.labour_line_items
    end
  end

  def subtotal
    self.quote_items.to_a.sum {|i| (i.total || 0.0) }
  end

  def total_minutes
    self.quote_items.to_a.sum {|i| (i.total_minutes || 0.0)}
  end

  def editable?
    if self.work_order.present?
      self.work_order.editable?
    else
      true
    end
  end

  def duplicate
    q = self.clone
    q.printed_at = nil
    q.created_at = Time.now
    q.updated_at = Time.now
    q.quote_items << self.quote_items.collect { |qi| qi.duplicate }
    q
  end

  private

  def work_order_is_editable?
    errors.add(:work_order, "must not have a PO number assigned to be able to edit.") if !self.new_record? and self.work_order.present? and ! self.work_order.editable?
  end
  def contactable_present?
    errors.add_to_base("Quote must have either a contact or a business associated with it") if self.contact.blank? && self.business.blank?
    errors.add_to_base("Contact must be in the specified business") if self.business.present? && self.contact.present? && self.contact.business != self.business
  end
  def set_rfq_completeness
    if self.request_for_quote
      self.request_for_quote.set_completeness!
      self.request_for_quote.save if self.request_for_quote.changed?
    end
  end
end

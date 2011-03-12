module QuotesHelper
  def setup_quote(quote)
    quote.quote_items.build if quote.quote_items.blank?
    quote
  end
  def setup_quote_item(item)
    item.name = "New Quote Item"
    item.markup = Settings.quote_item_markup
    item.hardware_markup = Settings.quote_item_hardware_markup
    item
  end
  def setup_product_line_item(pli)
    p = Product.first
    pli.product = p
    pli.dimension = (p.class == LengthProduct ? Settings.default_length_product_dimension : Settings.default_sheet_product_dimension)
    pli.order_quantity = 0
    pli.amount_needed = 0
    pli.product_consumed = 0
    pli.markup = Settings.product_markup
  end
  def setup_labour_line_item(lli)
    lli.workers = 0
    lli.setup_time = 0
    lli.run_time = 0
    lli.hourly_rate = Settings.labour_hourly_rate
    lli.markup = Settings.labour_markup
    lli
  end
  def setup_custom_line_item(cli)
    cli.cost_per_pound = 0
    cli.order_quantity = 0
    cli.product_consumed = 0
    cli.markup = Settings.custom_markup
  end
  
  def amount_suffix(product_or_class)
    if product_or_class.is_a?(Class)
      klass = product_or_class
    else
      klass = product_or_class.class
    end
    return "sq ft" if klass == SheetProduct
    return "ft" if klass == LengthProduct
    return "units" if klass == UnitProduct
  end

  def installation_text(quote)
    if quote.needs_installation
      "Supply and Installation"
    else
      "Supply Only"
    end
  end
  
  def quote_index_grid
    self.format_quote_grid!
    Quote.grid
  end

  def quote_quicksearch
    text_field_tag :quote_quicksearch, "Quote Quicksearch",
            :class              => "autocomplete quicksearch",
            :autocomplete_url    => autocomplete_for_quote_job_name_quotes_path,
            :success_url        => quotes_path
  end

  def quote_contact_autocomplete(quote)
    name = begin
      unless quote.contact.nil?
        quote.contact.name
      else
        ""
      end
    end
    text_field_tag :auto_contact_name, name,
            :class              => "autocomplete",
            :autocomplete_url    => autocomplete_for_contact_name_contacts_path,
            :data_update        => '#quote_contact_id',
            :data_scoped_by     => '#quote_business_id'
  end

  def quote_business_autocomplete(quote)
    name = unless quote.business.nil?
        quote.business.name
      else
        ""
      end
    text_field_tag :auto_business_name, name,
            :class              => "autocomplete",
            :autocomplete_url    => autocomplete_for_business_name_businesses_path,
            :data_update      => '#quote_business_id'
  end

  def format_quote_grid!
    Quote.grid.update({
    :title => "Quotes",
    :pager => true,
    :search_toolbar => :hidden,
    :resizable => false,
    :height => :auto,
    :except => [:contacts],
    :rows_per_page => 10}) { |grid|
      grid.column :id, :label => "Number", :width => 50#, :proc => lambda {|record| link_to record.number, quote_path(record) }
      grid.column :job_name, :width => 140, :proc => lambda {|record| link_to record.job_name, quote_path(record) }
      grid.column :category, :width => 60
      grid.column :needs_installation, :width => 60
      grid.column :contact_id, :hidden => true
      grid.column :business_id, :hidden => true
      grid.column :contact_name, :label => "Contact", :width => 100, :sortable => false, :proc => lambda {|record| link_to(record.contact.name, record.contact) if record.contact.present? }
      grid.column :business_name, :label => "Business", :width => 100, :sortable => false, :proc => lambda {|record| link_to(record.business.name, record.business) if record.business.present? }
      grid.column :scope_of_work_id, :hidden => true
      grid.column :markup, :hidden => true
      grid.column :notes, :hidden => true
      grid.column :shred, :hidden => true
      grid.column :printed_at, :hidden => true
      grid.column :created_at, :hidden => true
      grid.column :updated_at, :hidden => true
      grid.column :user_id, :hidden => true
      grid.column :actions, :width => 200, :sortable => false, :searchable => false, :proc => lambda {|record|
        permissioned_actions(record) do |p|
          p.show_link
          p.link('Printable', printable_quote_path(record), :show, record)
          p.edit_link
          p.destroy_link
          p.link('RFQ', request_for_quote_path(record.scope_of_work.request_for_quote_id), :show, record.scope_of_work) if record.scope_of_work.present?
          p.correspondence_link
          p.resources_link
          p.link(record.work_order.number, work_order_path(record)) if record.work_order
        end
      }
    }
  end

  def quote_work_order_link(quote)
    unless quote.work_order.present?
      link_to('Generate Work Order', generate_work_order_quote_path(quote))
    else
      link_to("View #{quote.work_order.number}", work_order_path(quote.work_order)) + " | " +
      link_to("Edit #{quote.work_order.number}", edit_work_order_path(quote.work_order)) + " | " +
      link_to("Work Order Queue", queue_work_orders_path())
    end
  end

end

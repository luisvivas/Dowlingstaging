module WorkOrdersHelper
  def work_order_quicksearch
		text_field_tag :auto_work_order_name, "Work Order Quicksearch",
						:class							=> "autocomplete quicksearch", 
						:autocomplete_url		=> autocomplete_for_work_order_name_work_orders_path, 
						:success_url				=> work_orders_path
	end
	
	def shift_queue_boxes(work_order)
	  # if the work order needs installation and the first class is complete, then don't display the first and display the last
	  work_order.products_available_status.complete? && work_order.needs_installation
	end
	def first_box_class(work_order)
    "not_super_important" if shift_queue_boxes(work_order)
	end
	def last_box_class(work_order)
    "not_super_important" unless shift_queue_boxes(work_order)
	end
	def second_last_box_class(work_order)
    "last" unless shift_queue_boxes(work_order)
	end
	def work_order_quote_autocomplete(work_order)
    name = unless work_order.quote.nil?
				work_order.quote.name_with_number
			else
				""
		  end
	  text_field_tag :auto_quote_name, name, 
						:class            => "autocomplete tooltip", 
						:autocomplete_url => autocomplete_for_quote_job_name_quotes_path,
						:data_update      => '#work_order_quote_id',
						:title            => "Enter the name or number of a quote above to generate a work order for it."
  end

	def work_order_index_grid
	  self.format_work_order_grid!
	  WorkOrder.grid
	end
	
	def format_work_order_grid!
	  WorkOrder.grid.update({
		:title => "Work Orders",
		:pager => true,
		:search_toolbar => :hidden,
		:resizable => false,
		:height => :auto,
		:rows_per_page => 10}) { |grid|
      grid.column :id, :width => 60, :label => "Number"#, :proc => lambda {|record| link_to record.number, work_order_path(record) }
      grid.column :quote, :width => 60, :proc => lambda {|q| link_to q.quote.number, quote_path(q) }
      grid.column :job_name, :width => 180, :proc => lambda {|record| link_to record.job_name, work_order_path(record) }
      grid.column :contact_name, :label => "Contact", :width => 100, :sortable => false, :proc => lambda {|record| link_to(record.contact.name, record.contact) if record.contact.present? }
      grid.column :business_name, :label => "Business", :width => 100, :sortable => false, :proc => lambda {|record| link_to(record.business.name, record.business) if record.business.present? }
      grid.column :created_at, :hidden => true
      grid.column :updated_at, :hidden => true
      grid.column :po_number, :hidden => true
      grid.column :quote_id, :hidden => true
      grid.column :complete, :width => 100
      grid.column :due_date, :width => 100, :date_format => 'ShortDate'
			grid.column :actions, :width => 200, :sortable => false, :searchable => false, :proc => lambda {|record|
			  permissioned_actions(record, " ") do |p|
      		p.trifecta
      		p.correspondence_link
      		p.link("Resources", quote_job_resources_path(record.id), :show, :job_resource)
      		p.text link_to_google_schedule(record), :show, record
        end
			}
    }
	end
	
	def link_to_google_schedule(work_order, text = "Schedule")
	  link_to(text, Settings.generic_calendar_url + "?q=#{CGI.escape(work_order.number)}", :target => "_blank")
	end
	
	def link_to_labour_line_item_schedule(lli, options = {})
	  options = {
	    :text => "#{lli.description} - #{lli.work_order.number}",
	    :details => "",
	    :location => "",
	    :website => url_for(lli.work_order),
	    :company_name => Settings.company_name,
	    :calendar => Settings.calendar_id,
	    :target => "_blank"
	  }.merge(options)
	  options[:calendar] = Base64.encode64(options[:calendar]).gsub("\n", '').gsub("=", '')
	  options.each {|k, v| options[k] = CGI::escape(v) if k != :calendar}
	  
	  url = "http://www.google.com/calendar/event?action=TEMPLATE&text=#{options[:text]}&details=#{options[:details]}&location=#{options[:location]}&trp=false&sprop=#{options[:site]}&sprop=name:#{options[:company_name]}&src=#{options[:calendar]}"
	  link_to google_calendar_img, url, :target => options[:target]
	end
	
	def google_calendar_img
	  image_tag "http://www.google.com/calendar/images/ext/gc_button1.gif"
	end
end

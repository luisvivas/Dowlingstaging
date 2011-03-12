module RequestForQuotesHelper

  def request_for_quote_quicksearch
    text_field_tag :rfq_quicksearch, "RFQ Quicksearch",
            :class              => "autocomplete quicksearch",
            :autocomplete_url    => autocomplete_for_request_for_quote_job_name_request_for_quotes_path,
            :success_url        => request_for_quotes_path
  end

  def request_for_quote_index_grid
    self.format_request_for_quote_grid!
    RequestForQuote.grid
  end

  def new_scope_duplicate_select(request)
    select_tag :duplicate_scope_id, options_for_select(request.scope_of_works.reject{|x| x.new_record?}.inject({" -- New Scope" => 0}) {|acc, x| acc[x.bidder.name] = x.id; acc }, params[:duplicate_scope_id] || 0)
  end

  def scope_identifier_link(scope)
    if scope.bidder.present?
      ("for " + link_to(scope.bidder.name, scope.bidder)).html_safe
    else
      link_to "#"+scope.id, scope
    end
  end

  def format_request_for_quote_grid!
    RequestForQuote.grid.update({
    :title => "Requests for Quotes",
    :pager => true,
    :search_toolbar => :hidden,
    :resizable => false,
    :height => :auto,
    :rows_per_page => 10}) {|grid|
      grid.column :id, :hidden => false, :width => 60#, :proc => lambda {|record| link_to record.number, request_for_quote_path(record)}
      grid.column :job_name, :proc => lambda {|record| link_to record.job_name, request_for_quote_path(record)}
      grid.column :category, :width => 80
      grid.column :bidders, :width => 200, :sortable => false, :searchable => false, :proc => lambda {|rfq|(rfq.contacts + rfq.businesses).collect {|c| link_to(c.name, c) }.to_sentence }
      grid.column :due_date, :width => 80, :date_format => 'ShortDate'
      grid.column :shred, :hidden => true
      grid.column :site_visit, :hidden => true
      grid.column :notes, :hidden => true
      grid.column :complete, :width => 60
      grid.column :bidding, :width => 60
      grid.column :business_id, :hidden => true
      grid.column :created_at, :hidden => true
      grid.column :updated_at, :hidden => true
      grid.column :actions, :width => 120, :sortable => false, :searchable => false, :proc => lambda {|record|
        permissioned_actions(record) do |p|
          p.trifecta
          p.correspondence_link
        end
      }
    }
  end
end

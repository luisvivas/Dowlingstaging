module BusinessesHelper  
  def setup_address(address)
    address.country = "CA" unless address.country
    address.state = "ON" unless address.state
    address
  end
    
  def business_index_grid
	  self.format_business_grid!
	  Business.grid
	end
	
	def business_quicksearch
		text_field_tag :business_quicksearch, "Business Quicksearch", {
						:class							=> "autocomplete quicksearch", 
						:autocomplete_url		=> autocomplete_for_business_name_businesses_path, 
						:success_url				=> businesses_path}
	end
	
	def business_bidder_autocomplete
		text_field_tag :auto_busines_bidder_name, "",
						:class							=> "autocomplete tooltip", 
						:autocomplete_url		=> autocomplete_for_bidder_name_businesses_path,
						:data_update        => '#scope_of_work_business_id',
						:title              => "Enter the name of a business above to add them as a bidder and create a scope of work."
	end
	
	
	def format_business_grid!
	  Business.grid.update({
		:title => "Businesses",
		:pager => true,
		:search_toolbar => :hidden,
		:resizable => false,
		:height => :auto,
		:except => [:contacts],
		:rows_per_page => 10}) { |grid|
			grid.column :name, :width => 200, :proc => lambda {|record| link_to record.name, business_path(record)}
			grid.column :email
			grid.column :telephone, :width => 110
			grid.column :address, :sortable => false, :hidden => true
			grid.column :created_at, :hidden => true
			grid.column :updated_at, :hidden => true
			grid.column :notes, :hidden => true
			grid.column :fax, :hidden => true
			grid.column :website, :hidden => true
			grid.column :bidder, :hidden => true
			grid.column :actions, :sortable => false, :searchable => false, :proc => lambda {|record| 
			  permissioned_actions(record) do |p|
			    p.show_link
			    p.link("Contacts", business_contacts_path(record), :show, Contact.new(:business => record))
          p.edit_link
  			  p.destroy_link
  			end
			}
		}
	end
end
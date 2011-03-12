module ContactsHelper
  def setup_addressable(addressable)
    returning(addressable) do |a|
      a.build_address if a.address.blank?
    end
  end
  
  def contact_quicksearch
		text_field_tag :contact_quicksearch, "Contact Quicksearch", 
						:class							=> "autocomplete quicksearch", 
						:autocomplete_url		=> autocomplete_for_contact_name_contacts_path, 
						:success_url				=> contacts_path
	end

	def contact_bidder_autocomplete
		text_field_tag :auto_bidder_name, "",
						:class							=> "autocomplete tooltip", 
						:autocomplete_url		=> autocomplete_for_bidder_name_contacts_path,
						:data_update        => '#scope_of_work_contact_id',
						:title              => "Enter the name of a contact above to add them as a bidder and create a scope of work."
	end

	def contact_business_autocomplete(contact)
		name = begin
			unless contact.business.nil?
				contact.business.name
			else
				""
			end
		end
		text_field_tag :auto_business_name, name, 
						:class							=> "autocomplete", 
						:autocomplete_url		=> autocomplete_for_business_name_businesses_path, 
						:data_update				=> '#contact_business_id',
						:success_url				=> businesses_path,
						:success_update			=> '#business_details'
	end
	
	def contact_index_grid
	  self.format_contact_grid!
	  Contact.grid
	end
	
	def contact_business_grid
	  self.format_contact_business!
	  Contact.grids[:business]
	end
	
	def format_contact_business!
	  self.format_a_contact_grid!(Contact.grids[:business]).update({
	    :name => :business,
	    :title => "Business Contacts",
	    :url =>  business_contacts_path(@business)
	  })
	end
	
	def format_contact_grid!
	  self.format_a_contact_grid!(Contact.grid)
	end
	def format_a_contact_grid!(which)
    which.update({
		:title => "Contacts",
		:pager => true,
		:search_toolbar => :hidden,
		:resizable => false,
		:height => :auto,
		:rows_per_page => 10}) { |grid|
			grid.column :first_name, :width => 100, :proc => lambda {|record| link_to(record.first_name, record)}
			grid.column :last_name, :width => 100, :proc => lambda {|record| link_to(record.last_name, record)}
			grid.column :business, :width => 200, :sortable => false, :searchable => false, :proc => lambda {|record| link_to(record.business.name.to_s, business_path(record.business)) if record.business.present?}
			grid.column :business_id, :hidden => true
			grid.column :email, :width => 150
			grid.column :telephone, :width => 110
			grid.column :address, :sortable => false, :hidden => true
			grid.column :created_at, :hidden => true
			grid.column :updated_at, :hidden => true
			grid.column :department, :hidden => true
			grid.column :fax, :hidden => true
			grid.column :mobile, :hidden => true
			grid.column :bidder, :hidden => true
			grid.column :actions, :sortable => false, :searchable => false, :proc => lambda {|record| 
			  permissioned_actions(record) do |p|
			    p.show_link
          p.edit_link
  			  p.destroy_link
  			end
			}
    }
	end
end

module CorrespondencesHelper
  def format_correspondence_contact(c, which = :to, links = true)
    if which == :to
      email = c.to_email
      name = c.to_name
    else
      email = c.from_email
      name = c.from_name
    end

    # from  incoming -> contact
    # from  outgoing -> user
    # to    incoming -> user    
    # to    outgoing -> contact
    if (which == :to) ^ (c.outgoing)
      obj = c.user
    else
      obj = c.contact
    end
    
    if obj.present?
      ret = obj.name 
      ret += " [#{link_to("Show", obj)} #{mail_to(obj.email, "Mail")}]" if links
    else
      if name.present?
        ret = name 
      else
        ret = email
      end
      ret += " [#{mail_to(email, "Email")}]"
    end
    ret.html_safe
  end
  
  def who_sent_what(c)
    if c.outgoing
      format_correspondence_contact(c, :from) + " sent an email " + link_to_subject(c) + " to " + format_correspondence_contact(c, :to)
    else
      format_correspondence_contact(c, :to) + " received an email " + link_to_subject(c) + " from " + format_correspondence_contact(c, :from)
    end
  end
  
  def link_to_subject(c)
    ("\"" + link_to(truncate(c.subject), polymorphic_path([c.discussable, c])) + "\"").html_safe
  end
  
  def correspondence_index_grid(parent)
	  self.format_correspondence_grid!
	  Correspondence.grid.update(:url => polymorphic_path([parent, Correspondence.new]))
	end
		
	def format_correspondence_grid!
	  Correspondence.grid.update({
		:title => "Correspondence",
		:pager => true,
		:search_toolbar => :hidden,
		:resizable => false,
		:height => :auto,
		:rows_per_page => 10}) {|grid|
		  grid.column :to_email, :hidden => true
		  grid.column :from_email, :hidden => true
		  grid.column :to_name, :hidden => true
  	  grid.column :from_name, :hidden => true
  	  grid.column :user_id, :hidden => true
  	  grid.column :contact_id, :hidden => true
  	  grid.column :discussable_id, :hidden => true
  	  grid.column :discussable_type, :hidden => true
  	  grid.column :outgoing, :hidden => true
  	  grid.column :attachments, :hidden => true
  	  grid.column :updated_at, :hidden => true
  	  grid.column :body, :hidden => true
  	  grid.column :to, :proc => lambda {|c| format_correspondence_contact(c, :to, false) }
  	  grid.column :from, :proc => lambda {|c| format_correspondence_contact(c, :from, false) }
  	  grid.column :created_at, :label => "Sent"
  	  grid.column :subject
			grid.column :actions, :sortable => false, :searchable => false, :proc => lambda {|record| 
			  link_to("Show", polymorphic_path([record.discussable, record])) + " " +
			  link_to('Destroy', polymorphic_path([record.discussable, record]), :confirm => destroy_confirmation(record), :method => :delete)
			}
    }
	end
end

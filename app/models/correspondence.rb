class Correspondence < ActiveRecord::Base
  thwart_access
  
  WatchDomain = "watch.dowlingmetal.com"
  RealDomain = "dowlingmetal.com"
  DiscussionTag = "!!"
  belongs_to :discussable, :polymorphic => true
  belongs_to :contact
  belongs_to :user
  validates_presence_of :to_email, :from_email, :subject, :body
  
  before_save :find_discussables
  
  class << self
    attr_accessor :discussable_models
    def discussable_models
      @discsussable_models ||= []
    end
    
    def discussable_tags
      self.discussable_models.map {|m| m.discussable_tag }
    end
    
    def new_from_sendgrid(params)
      require 'mail'
      require 'iconv'
      encodings = ActiveSupport::JSON.decode(params[:charsets])
      # Sendgrid auto-decodes the headers into UTF8
      mail = Mail.new(params[:headers])
      mail.text_part = Mail::Part.new(:charset => 'UTF-8', :content_type => "text/plain;", :body => Iconv.conv(encodings['text']+"//IGNORE", 'UTF-8', params[:text])) if params[:text].present?
      mail.html_part = Mail::Part.new(:charset => 'UTF-8', :content_type => "text/html;", :body => Iconv.conv(encodings['html']+"//IGNORE", 'UTF-8', params[:html])) if params[:html].present?
      self.new_from_mail(mail)
    end

    def new_from_mail(mail)
      require 'mail'

      attributes = {}
      ['to', 'from'].each do |sym|
        attributes[(sym+'_email').intern]   = mail[sym.intern].addresses.map{|a| internalize_watch_email(a) }.join(", ")
        attributes[(sym+'_name').intern]    = mail[sym.intern].display_names.join(", ")
      end

      # Figure out if the email came in to the buisness or was sent by the business
      if(mail.to_addrs.any? {|x| x.match(self::WatchDomain)})
        # Incoming mail. To Us, from Them
        attributes[:outgoing] = false
        internal_email = attributes[:to_email]
        external_email = attributes[:from_email]
      else
        # Outgoing mail. From Us, To Them
        attributes[:outgoing] = true
        internal_email = attributes[:from_email]
        external_email = attributes[:to_email]
      end
      attributes[:subject]      = mail.subject
      attributes[:body]         = mail.text_part.decoded
      attributes[:user]         = User.find_by_email(internal_email)
      attributes[:contact]      = Contact.find_by_email(external_email)
      attributes[:attachments]  = mail.attachments.length
      self.new(attributes)
    end

    def internalize_watch_email(email)
      email.gsub(self::WatchDomain, self::RealDomain)
    end

    def update_added_contact(c)
      update_added_email_obj(c, "contact")
    end

    def update_added_user(c)
      update_added_email_obj(c, "user")
    end

    def update_added_email_obj(obj, type)
      correspondence = Correspondence.where(type+"_id IS NULL AND (to_email = ? OR from_email = ?)", obj.email, obj.email)
      correspondence.each do |c|
        c.send((type+"=").intern, obj)
        c.save
      end
    end
    
    def parent_id_from_params(params)
      params.find {|k,v| k.to_s.include?("_id")}[1].to_i
    end
    def parent_type_from_params(params)
      params.find {|k,v| k.to_s.include?("_id")}[0].to_s.split('_').first.capitalize
    end
  end
  
  scope :with_details, includes(:contact, :user, :discussable)
  scope :in_received_order, order("created_at DESC")
  scope :recent, with_details.where("discussable_id IS NOT NULL").in_received_order.limit(20)
  
  scope :discussable_grid_conditions, lambda { |grid, params|
	  where(:discussable_id => parent_id_from_params(params), :discussable_type => parent_type_from_params(params))
	} 
	scope :contact_grid_conditions, lambda { |grid, params| 
	  where(:contact_id => params[:contact_id])
	}
	scope :grid_conditions, lambda { |grid, params| 
	  scoped.discussable_grid_conditions(grid, params)
	}
  scope :find_for_grid, lambda { |grid, params|
	  with_details.grid_conditions(grid, params).in_received_order
	}	
	scope :count_for_grid, lambda { |grid, params|
	  scoped.grid_conditions(grid, params)
	}
	
	gridify do |grid|
    # grid.column :contact, :proc => lambda {|c| c.contact.name.to_s }
    # grid.column :user, :proc => lambda {|c| c.user.name.to_s }
    # grid.column :discussable, :proc => lambda {|c| c.discussable.number }
	end
	
  def incoming?
    !self.outgoing
  end
  
  def outgoing?
    self.outgoing
  end
  
  def find_discussables
    Quote
    RequestForQuote
    ts = Correspondence.discussable_tags.map {|t| Regexp.escape(t) + "#?" }
    regex = "\\["+Correspondence::DiscussionTag + "(" + ts.join("|") + ")([0-9]+?)\\]"
    matches = self.body.match(regex)
    if matches.present?
      discussable_tag, discussable_id = matches[1].gsub('#',''), matches[2].to_i
      Correspondence.discussable_tags.each_with_index do |tag, i|
        begin
          self.discussable = Correspondence.discussable_models[i].find(discussable_id) if tag == discussable_tag
        rescue ActiveRecord::RecordNotFound
        end
      end
    end
    true
  end
end

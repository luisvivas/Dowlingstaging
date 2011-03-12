class JobResource < ActiveRecord::Base
  thwart_access
  
  def self.categories
    ["General", "Site Photo", "Shop Drawing"]
  end

  belongs_to :attachable, :polymorphic => true
  has_attached_file :resource, 
      :storage => :s3,
      :s3_credentials => "#{Rails.root}/config/s3.yml",
      :path => ":attachment/:id/:style/:basename.:extension",
      :styles => {:thumb => ["150x150>", :jpg]}
  
  validates_presence_of :name, :attachable
  
  validates_attachment_presence :resource
  
  before_resource_post_process :image?
  def image?
    return (self.resource.content_type =~ /^image.*/) ? true : false
  end
    
end
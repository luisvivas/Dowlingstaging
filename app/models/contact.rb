class Contact < ActiveRecord::Base
  thwart_access
  include KCPMS::Contactable

  belongs_to :business

  validates_presence_of :first_name, :last_name
  validates_presence_of :telephone, :if => Proc.new {|c| c.business.present? }
  validates_uniqueness_of :email, :message => "is already assigned to a contact in the system.", :if => Proc.new {|contact| ! contact.email.blank? }
  validates_length_of :first_name, :in => 2..200
  validates_length_of :last_name, :in => 2..200

  scope :find_for_grid, lambda { |grid, params|
    grid_scope = includes(:business, :address)
    case grid
    when :business
      grid_scope = grid_scope.where(:business_id => params[:business_id])
    end
    grid_scope
  }

  grid_base = Proc.new do |grid|
    grid.column :business, :proc => lambda {|contact| contact.business.name.to_s if contact.business.present? }
    grid.column :address, :proc => lambda {|contact| contact.address.to_s }
  end

  gridify &grid_base
  gridify :business, &grid_base

  def name
    [self.first_name, self.last_name].join(" ")
  end

  def to_s
    self.name
  end

  def more_than_one_phone?
    [self.telephone, self.mobile, self.fax].count{|x| !x.blank? } > 1
  end
end

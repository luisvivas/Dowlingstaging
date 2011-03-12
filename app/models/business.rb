class Business < ActiveRecord::Base
  thwart_access
  include KCPMS::Contactable

  validates_presence_of :name, :telephone

  scope :find_for_grid, lambda{|name, params| includes(:address)}
  scope :count_for_grid
  
  gridify do |grid|
    grid.column :address, :proc => lambda {|business| business.address.to_s }
  end

  def to_s
    self.name
  end

  def more_than_one_phone?
    [self.telephone, self.fax].count{|x| !x.blank? } > 1
  end
end

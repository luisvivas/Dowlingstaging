class User < ActiveRecord::Base
  include SentientUser
  thwart_access
  devise :rememberable, :trackable, :timeoutable, :imap_authenticatable
  attr_accessible :first_name, :last_name, :role, :email, :home_phone, :cell_phone, :employee_number, :password, :remember_me # set up accessible attributes from Devise
  
  include Thwart::Actor
  
  thwart_access do
    role_method :role
    default_role :employee
  end
  
  def self.available_roles
    ["employee", "manager", "administrator"]
  end
  
  has_one :address, :dependent => :destroy, :as => :addressable
  accepts_nested_attributes_for :address
  has_many :work_orders
  accepts_nested_attributes_for :work_orders, :allow_destroy => false
  
  validates_presence_of :email
  validates_uniqueness_of :email
  validates_associated :address
  
  # Find the User gridification in config/initializers/users.rb because Devise preloads the user model,
  # and gridify tries to get at ActiveRecord before its defined. Lame, it has to be done in an initializer
  # after Rails has booted properly.
  scope :find_for_grid
  gridify :build_model => false 
 
  format_phones 
  
  def has_filled_out_profile?
    first_name.present? && last_name.present?
  end
  
  def name
    s = ""
    s += self.first_name if self.first_name.present? 
    s += " " + self.last_name if self.last_name.present?
    if s == ""
      s = self.email
    end
    s
  end
  
  def best_identifier(long = false)
    return self.name unless self.name.blank?
    return self.email
  end
end

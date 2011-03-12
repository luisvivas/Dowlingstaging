class Address < ActiveRecord::Base
  thwart_access
  
  belongs_to :addressable, :polymorphic => true

  #validates_presence_of :street1, :city, :zipcode, :country
  validate :state_must_belong_to_country, :if => Proc.new {|a| a.country.present? && Carmen::states?(a.country) }
  validate :valid_zipcode, :if => Proc.new {|a| a.zipcode.present? }

  before_save :ensure_no_state_if_country_has_no_states
  before_validation :strip_zipcode
  
  
  def zipcode
    if @attributes['zipcode']
      case self.country
      when "CA"
        @attributes['zipcode'][0..2].to_s + " " + @attributes['zipcode'][3..-1].to_s
      else
        @attributes['zipcode']
      end
    end
  end

  def to_s
    a = []
    [self.street1, self.street2, self.city, self.state, self.zipcode].each do |x|
      a.push x unless x.blank?
    end
    a << Carmen::country_name(self.country) if self.country != Carmen.default_country
      
    a.join(", ")
  end
  
  def foo
    "foo"
  end
  
  def baz
    "baz"
  end
  
  private

  def state_must_belong_to_country
    errors.add(:state, "must belong to the selected country") if Carmen::state_name(self.state, self.country).nil?
  end

  def ensure_no_state_if_country_has_no_states
    unless self.country && Carmen::states?(self.country) 
      self.state = nil
    end
  end

  def strip_zipcode
    @attributes['zipcode'] = @attributes['zipcode'].gsub(/\s/, '').upcase if @attributes['zipcode']
  end

  def valid_zipcode
    case self.country
    when "CA"
      errors.add(:zipcode, "must have a valid Canadian postal code of the form A1B 2C3") unless @attributes['zipcode'] =~ /[A-Z]\d[A-Z]\d[A-Z]\d/
    when "US"
      errors.add(:zipcode, "must have a valid American zip code of the form 55555") unless @attributes['zipcode'] =~ /\d{5}(-\d{4})?/
    else
      true
    end
  end
end
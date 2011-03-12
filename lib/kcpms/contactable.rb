module KCPMS
  module Contactable
    def self.included(base)
      base.has_one :address, :dependent => :destroy, :as => :addressable
      base.accepts_nested_attributes_for :address
      base.validates_associated :address

      base.has_many :scope_of_works, :dependent => :destroy
      base.has_many :quotes, :dependent => :destroy
    
      base.format_phones
    end
  end
end

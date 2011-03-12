module KCPMS
  module TelephoneFormatting
    include ActionView::Helpers::NumberHelper
    mattr_accessor :keys
    @@keys = [:telephone, :cell_phone, :home_phone, :mobile, :fax]
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      
      def format_phones
        send :include, InstanceMethods
        validate :phonenumbers_correct
        before_save :strip_phonenumbers!
        after_save :format_phonenumbers            
        after_find :format_phonenumbers
      end
    end
    
    module InstanceMethods
      def strip_phonenumbers!
        self.phone_keys.each do |key|
          write_attribute(key, self.read_attribute(key).to_s.gsub(/[^0-9]/, '')) if read_attribute(key).present?
        end
      end
      
      def format_phonenumbers
        strip_phonenumbers!
        self.phone_keys.each do |key|
          val = read_attribute(key)
          if val.present? && val != ""
            options = {:area_code => true}
            options[:extension] = val[10..-1].to_i if val.length > 10
            core = val[0..9].to_i
            write_attribute(key, number_to_phone(core, options)) if core.present?
          end
        end
      end
      
      def phonenumbers_correct
        strip_phonenumbers!
        self.phone_keys.each do |key|
          if self.read_attribute(key).present?
            errors.add(key, "must be 10 or more digits long") if read_attribute(key).length < 10
          end
        end
      end
      
      def phone_keys 
        KCPMS::TelephoneFormatting.keys.reject {|key| !self.respond_to?(key) }
      end        
    end
  end
end

ActiveRecord::Base.send :include, KCPMS::TelephoneFormatting
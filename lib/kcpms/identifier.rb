module KCPMS::BetterIdentification
  def best_identifier(long = false)
    resource_name = self.name if self.respond_to?(:name)
    resource_name ||= self.job_name if self.respond_to?(:job_name) if long
    resource_name ||= self.title if self.respond_to?(:title)
    resource_name ||= self.number if self.respond_to?(:number)
    resource_name ||= self.to_s if self.respond_to?(:to_s) if long
    resource_name ||= "##{self.id}"
    resource_name
  end
end

ActiveRecord::Base.send(:include, KCPMS::BetterIdentification)
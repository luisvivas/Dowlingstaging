module Discussable
  def self.included(base)
    Correspondence.discussable_models = (Correspondence.discussable_models << base)
    base.has_many :correspondences, :as => :discussable, :dependent => :destroy
    base.extend ClassMethods
  end
  module ClassMethods
    attr_accessor :discussable_tag
    def discussed_using(string)
      self.discussable_tag = string
    end
  end
  
  def discussion_tag
    self.class.discussable_tag + "#" + self.id.to_s
  end
end
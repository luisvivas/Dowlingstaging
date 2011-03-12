class FeedItem < ActiveRecord::Base
  
  belongs_to :resource, :polymorphic => true, :validate => false
  belongs_to :user, :validate => false
  
  validates_presence_of :resource
  
  def user_name
    return self.user.best_identifier if self.user.present?
    return "System"
  end
end

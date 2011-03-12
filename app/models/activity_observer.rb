class ActivityObserver < ActiveRecord::Observer
  
  TRACKED_MODELS = {
                    :address => false,
                    :business => true,
                    :contact => true,
                    :product => true,
                    :product_category => true,
                    :product_size => false,
                    :quote => true,
                    :quote_item => false,
                    :request_for_quote => true,
                    :scope_of_work => true,
                    :scope_item => false,
                    :user => true,
                    :job_resource => true,
                    :work_order => true
                    }
  
  observe TRACKED_MODELS.map {|k, v| k }
  
  def after_create(model)
    track_activity("created", model)
  end
  
  def after_update(model)
    track_activity("updated", model)
  end
  
  def after_destroy(model)
    track_activity("destroyed", model)
  end 

  def track_activity(type, model)
    key = model.class.name.tableize.singularize.intern
    if self.class::TRACKED_MODELS.include?(key)
      current_user = User.current if  User.current.present?
      current_user ||= nil
      FeedItem.create(:resource => model, :activity_type => type, :user => current_user, :feed_display => self.class::TRACKED_MODELS[key])
    end
  end
  
end

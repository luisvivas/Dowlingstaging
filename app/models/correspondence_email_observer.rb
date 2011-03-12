class CorrespondenceEmailObserver < ActiveRecord::Observer
  observe :contact, :user
  def after_save(obj)
  	Correspondence.update_added_email_obj(obj, obj.class.name.downcase) 
  end
end
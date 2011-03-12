module DashboardHelper
  def feed_listing(feed)
    custom_method_name = (feed.resource.class.name.tableize.singularize + "_feed_link").intern
    
    if feed.activity_type != "destroyed" && feed.resource.present?
      if self.respond_to?(custom_method_name)
        resource_link = self.send(custom_method_name, feed.resource)
      else
        resource_name = feed.resource.best_identifier(true)
        resource_link = link_to(resource_name, polymorphic_path(feed.resource))
      end
      resource_type = feed.resource.class.name.underscore.humanize.titleize
    else
      resource_link = "##{feed.resource_id} (destroyed)"
      resource_type = feed.resource_type.underscore.humanize.titleize
    end
    "#{feed.user_name} #{feed.activity_type} #{resource_type} ".html_safe + resource_link
  end
    
  def scope_of_work_feed_link(scope)
    "for ".html_safe + link_to(scope.bidder.name, scope.bidder) + " on RFQ ".html_safe + link_to(scope.request_for_quote.job_name, scope.request_for_quote)
  end
  
  def job_resource_feed_link(resource)
    link_to(resource.name, resource.resource.url) + " on " + link_to(resource.attachable.best_identifier, polymorphic_path(resource.attachable))
  end

  def viewable_hours_column
    if current_user.can_show?(:end_of_day_report_estimates)
      ""
    else
      'style="display:none;"'.html_safe
    end
  end
end

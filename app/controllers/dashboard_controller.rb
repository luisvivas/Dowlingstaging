class DashboardController < ApplicationController
  before_filter :authenticate_user!
  def index
    @feed = FeedItem.where(:feed_display => true).order("updated_at DESC").includes(:user, :resource).limit(20)
    @rfqs = RequestForQuote.queue.limit(5)
    @work_orders = WorkOrder.queue.limit(5)
    @correspondences = Correspondence.recent
  end
  
  def settings
    thwart_access(:settings, :update)
    @settings = Settings.all
    if params[:settings]
      params[:settings].each do |k,v|
        Settings[k] = v
      end
      flash[:notice] = "Settings succesfully updated."
    end
  end
end
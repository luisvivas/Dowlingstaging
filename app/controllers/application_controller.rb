class ApplicationController < ActionController::Base
  include ApplicationHelper
  include Thwart::Enforcer
  include SentientController
  
  # protect_from_forgery
  self.responder = ThwartedResponder
  layout Proc.new { |controller| controller.request.xhr? ? 'ajax' : 'application' }
  before_filter :grid, :unless => Proc.new {|cc| cc.devise_controller? }
  before_filter :check_user_profile
  
  helper :all
  
  rescue_from Thwart::NoPermissionError, :with => :no_permission
  private
  
  # Override the devise helper. This is only called when there is no redirect (stored location) already
  def after_sign_in_path_for(resource)
    if resource.is_a?(User) && !resource.has_filled_out_profile?
      display_new_user_profile_message # in application controller
      return edit_user_path(resource)
    else
      super
    end
  end
  
  def check_user_profile
    if user_signed_in? && !current_user.has_filled_out_profile?
      display_new_user_profile_message # in application controller
    end
  end
  
  # Return the grid XML
  def grid
    if !params[:grid].blank?
      # Find the model
      @model = self.class.name.gsub('Controller', '').singularize.constantize
      # Find the name of the method to call to format the grid and responses
      @format_method_name = "format_#{@model.name.tableize.singularize}_#{params[:grid]}!"
      # Symbolize the grid
      @grid_sym = params[:grid].to_sym      
      
      # Generate XML in the context of a view with all the helpers
      @grid = @model.grids[@grid_sym]
      render 'grid/grid'
    else
      return true
    end
  end  
  
  # No permission error handler
  def no_permission(exception)
    flash[:error] = ("You don't have permission to do that. If you believe this is an error, please contact " + self.class.helpers.mail_to(Settings.administrator_email, 'the administrator')).html_safe
    redirect_to :root
  end
end
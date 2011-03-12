class CorrespondencesController < ApplicationController
  respond_to :html
  before_filter :authenticate_user!, :except => [:create]
  
  def index
    @parent = parent_object
    @correspondences = @parent.correspondences
    respond_with(@correspondences)
  end

  def show
    @correspondence = Correspondence.with_details.where(:discussable_id => parent_object.id).find(params[:id])
    respond_with(@correspondence)
  end

  # Gets hit by the SendGrid API
  def create
    @correspondence = Correspondence.new_from_sendgrid(params)
    @correspondence.save
    render :text => "Saved", :status => 200
  end

  def destroy
    @correspondence = Correspondence.find(params[:id])
    @correspondence.destroy
    redirect_to polymorphic_path([@correspondence.discussable, :correspondences])
  end
  
  private 
  def parent_object
    case
      when params[:request_for_quote_id] then RequestForQuote.find_by_id(params[:request_for_quote_id])
      when params[:quote_id] then Quote.find_by_id(params[:quote_id])
      when params[:work_order_id] then WorkOrder.find_by_id(params[:work_order_id])
    end
  end
end

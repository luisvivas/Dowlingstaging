class WorkOrdersController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json
  
  autocomplete_for :work_order, :name, :joins => :quote, :match => ["CAST(quotes.id as text)", :job_name] do |orders|
    orders.map{|wo| "#{wo.name_with_number_and_contactable} --- #{wo.id}"}.join("\n")
  end
  
  def index
  end

  def queue
    @work_orders = WorkOrder.queue
    respond_with(@work_orders, :thwart_action => :show, :thwart_resource => :work_order_queue)
  end
  
  def show
    @work_order = WorkOrder.with_quote_details.find(params[:id])
    respond_with(@work_order)
  end

  def printable
    @work_order = WorkOrder.with_quote_details.find(params[:id])
    thwart_access(@work_order, :show)
    render :layout => 'printable'
  end


  def new
    @work_order = WorkOrder.new
    respond_with(@work_order)
  end

  def create
    begin
      @quote = Quote.find(params[:work_order][:quote_id])      
    rescue ActiveRecord::RecordNotFound
      @work_order = WorkOrder.new
      flash[:error] = "The quote you specified could not be found, please try again."
      render :new
    else
      @work_order = @quote.to_work_order
      flash[:notice] = "#{@work_order.number} was successfully created." if @work_order.save
      respond_with(@work_order)
    end
  end

  def edit
    @work_order = WorkOrder.with_quote_details.find(params[:id])
    respond_with(@work_order)
  end

  def update
    @work_order = WorkOrder.with_quote_details.find(params[:id])
    flash[:notice] = 'Work order was successfully updated.' if @work_order.update_attributes(params[:work_order])
    respond_with(@work_order)
  end

  def destroy
    @work_order = WorkOrder.find(params[:id])
    @work_order.destroy
    respond_with(@work_order)
  end
  
  # For chained select on dashboard
  def quote_items
    @items = QuoteItem.where(:quote_id => params[:q])
    # Put in chained select JSON format
    @items = @items.collect {|p| {:id => p.id, :text => p.name}}
    respond_with(@items, :thwart_action => :show, :thwart_resource => :end_of_day_report)
  end
end

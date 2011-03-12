class QuotesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :fetch_category_roots, :only => [:new, :create, :edit, :update]
  
  respond_to :html

  autocomplete_for :quote, :job_name, :match => ["CAST(id as text)", :job_name] do |quotes|
    quotes.map{|q| "#{q.name_with_number} --- #{q.id}"}.join("\n")
  end
  
  def index
    respond_with(Quote.new)
  end

  def show
    @quote = Quote.with_all_details.find(params[:id])
    respond_with(@quote)
  end

  def printable
    @quote = Quote.with_all_details.find(params[:id])
    thwart_access(@quote, :show)
    
    @quote.printed_at = Time.now
    @quote.save!
    @user = @quote.user
    render :layout => 'letter'
  end
  
  def new
    @quote = Quote.new(:markup => Settings.quote_markup, :user => current_user)
    respond_with(@quote)
  end

  def edit
    @quote = Quote.with_all_details.find(params[:id])
    respond_with(@quote)
  end

  def create
    @quote = Quote.new(params[:quote])
    flash[:notice] = 'Quote was successfully created.' if @quote.save
    respond_with(@quote)
  end

  def update
    @quote = Quote.with_all_details.find(params[:id])
    flash[:notice] = 'Quote was successfully updated.' if @quote.update_attributes(params[:quote])
    respond_with(@quote)
  end

  def destroy
    @quote = Quote.find(params[:id])
    @quote.destroy
    respond_with(@quote)
  end
  
  def generate_work_order
    @quote = Quote.find(params[:id])
    if @quote.work_order.present?
      flash[:notice] = "The work order for #{@quote.number} already exists!"
      redirect_to @quote.work_order
      return
    end
    
    @work_order = @quote.to_work_order
    if @work_order.save
      flash[:notice] = 'Work Order was successfully generated'
      redirect_to @work_order
    else
      flash[:error] = 'There was a problem generating the work order because '+@work_order.errors.full_messages.to_sentence+". Please try again."
      redirect_to @quote
    end
  end
  
  private 
  def fetch_category_roots
    @category_roots = ProductCategory.roots
  end
end

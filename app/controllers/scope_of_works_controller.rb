class ScopeOfWorksController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json
  before_filter :find_rfq, :only => [:new, :create]

  def show
    @scope = ScopeOfWork.find(params[:id])
    redirect_to request_for_quote_path(@scope.request_for_quote_id)
  end

  def new
    @scope = @request.scope_of_works.build(params[:scope_of_work])
    respond_with(@scope)
  end

  def create
    if params[:duplicate_scope_id] != "0"
      to_duplicate = ScopeOfWork.find(params[:duplicate_scope_id])
      @scope = to_duplicate.duplicate
      @scope.request_for_quote = @request
      @scope.contact_id = params[:scope_of_work][:contact_id] # nil here is good, reset the duplicated scope's bidder
      @scope.business_id = params[:scope_of_work][:business_id]
    else
      @scope = @request.scope_of_works.build(params[:scope_of_work])
    end

    if @scope.save
      flash[:notice] = "Scope of Work successfully created"
      redirect_to edit_request_for_quote_path(@request)
    else
      render :action => :new
    end
  end

  def destroy
    @scope = ScopeOfWork.find(params[:id])
    @scope.destroy
    flash[:notice] = "Scope of Work successfully destroyed."
    redirect_to edit_request_for_quote_path(@scope.request_for_quote)
  end

  def generate_quote
    @scope = ScopeOfWork.find(params[:id])
    @quotes = @scope.request_for_quote.scope_of_works.map(&:quotes).flatten
  end

  def generate_new_quote
    @scope = ScopeOfWork.find(params[:id])
    quote = @scope.to_quote(current_user)
    flash[:notice] = "Quote ##{quote.id} generated successfully." if quote.save
    redirect_to edit_quote_path(quote)
  end

  def duplicate_quote
    @scope = ScopeOfWork.find(params[:id])
    quote_id = params[:quote_id] || params[:quote][:id]
    @quote = Quote.find(quote_id)
    new_quote = @quote.duplicate
    new_quote.scope_of_work = @scope
    new_quote.contact = @scope.contact
    new_quote.business = @scope.business
    new_quote.job_name = @scope.request_for_quote.job_name
    flash[:notice] = "Quote ##{new_quote.id} generated successfully." if new_quote.save
    redirect_to edit_quote_path(new_quote)
  end

  def lead_letter
    @scope = ScopeOfWork.find(params[:id])
    thwart_access(@scope, :show)
    render :layout => 'letter'
  end

  private
  def find_rfq
     @request = RequestForQuote.find(params[:request_for_quote_id])
  end
end

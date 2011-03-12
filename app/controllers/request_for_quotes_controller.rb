class RequestForQuotesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html
  
  autocomplete_for :request_for_quote, :job_name, :match => ["CAST(id as text)", :job_name] do |quotes|
    quotes.map{|q| "#{q.number} #{q.job_name} --- #{q.id}"}.join("\n")
  end
  
  def index
  end

  def queue
    @request_for_quotes = RequestForQuote.queue
    @request_for_quotes
    respond_with(@request_for_quotes, :thwart_action => :show, :thwart_resource => :rfq_queue)
  end
  
  def show
    @request_for_quote = RequestForQuote.find(params[:id])
    respond_with(@request_for_quote)
  end

  def new
    @request_for_quote = RequestForQuote.new
    respond_with(@request_for_quote)
  end

  def edit
    @request_for_quote = RequestForQuote.find(params[:id])
    respond_with(@request_for_quote)
  end

  def create
    @request_for_quote = RequestForQuote.new(params[:request_for_quote])
    flash[:notice] = 'RFQ was successfully created.' if @request_for_quote.save
    respond_with(@request_for_quote)
  end

  def update
    @request_for_quote = RequestForQuote.find(params[:id])
    flash[:notice] = 'RFQ was successfully updated.' if @request_for_quote.update_attributes(params[:request_for_quote])
    respond_with(@request_for_quote)
  end

  def destroy
    @request_for_quote = RequestForQuote.find(params[:id])
    @request_for_quote.destroy
    respond_with(@request_for_quote)
  end
end
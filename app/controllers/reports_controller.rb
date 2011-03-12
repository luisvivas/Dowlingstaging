class ReportsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html
  
  layout Proc.new {|controller|
    if params[:printable] == "true"
      "printable"
    else
      "application"
    end
  }
    
  before_filter do 
    thwart_access(:reports, :show)
  end
  
  def index
  end
  
  def profitability
    @work_order = WorkOrder.find(params[:id])
    respond_with(@work_order, :thwart_action => :show)
  end
  
  def ordering
    @line_items = ProductLineItem.unordered_aggregate
  end
  
  def time_sheet
    begin
      @start = Date.parse(params[:start_date])
      @end = Date.parse(params[:end_date])
    rescue ArgumentError
      flash[:error] = "You must specify a valid date range to view a time sheet, please try again."
      redirect_to reports_path
    else
      @user = User.find(params[:id])
      @reports = EndOfDayReport.aggregate_in_range(@user.id, @start, @end)
      @total = @reports.inject(0) do |acc, (date, info)|
        acc += info[:sum]
        acc
      end
    end
  end
end

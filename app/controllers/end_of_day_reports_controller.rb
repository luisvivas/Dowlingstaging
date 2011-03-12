class EndOfDayReportsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_work_orders
  respond_to :html

  def new
    @report = EndOfDayReport.new(:user => current_user, :extra_hours => 0.0)
    @work_orders = WorkOrder.active.includes(:quote).order(:id).all
  end

  def create
    @report = EndOfDayReport.new(params[:end_of_day_report])
    items = @report.quote_items.collect(&:labour_line_items).flatten.collect(&:time_reports).flatten.reject{|x| x.end_of_day_report_id.present? }
    items.each do |x|
      x.end_of_day_report = @report
    end
    
    if @report.save
      items.each(&:save)
      flash[:notice] = "Report filed successfully."
      if params[:end_of_day_report][:sign_out_after] == "1"
        redirect_to destroy_user_session_path and return
      else
        redirect_to root_path and return
      end
    end
    respond_with(@report)
  end

  def show
    @quote_item = QuoteItem.includes([{:product_line_items => [:product, :product_size]}, :labour_line_items]).find(params[:id])
    respond_with(@quote_item)
  end

  private
  def find_work_orders
    @work_orders = WorkOrder.includes(:quote).active
  end
end

class JobResourcesController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html

  def index
    @parent = parent_object
    @resources = @parent.job_resources
    respond_with(@resources)
  end

  def new
    @resource = parent_object.job_resources.build
    respond_with(@resource)
  end

  def create
    @resource = JobResource.new(params[:job_resource])
    if @resource.save
      flash[:notice] = 'Job Resource was successfully uploaded.'
      unless request.env["HTTP_REFERER"].match("job_resources/new")
        redirect_to(edit_polymorphic_path(@resource.attachable))
      else
        redirect_to(polymorphic_path([@resource.attachable, JobResource.new]))
      end
    else
      render :action => "new"
    end
  end

  def destroy
    @resource = JobResource.find(params[:id])
    flash[:notice] = 'Job Resource was successfully destroyed.' if @resource.destroy
    redirect_to(polymorphic_path([@resource.attachable, JobResource.new]))
  end

  private
  def parent_object
    case
      when params[:request_for_quote_id] then RequestForQuote.find_by_id(params[:request_for_quote_id])
      when params[:quote_id] then Quote.find_by_id(params[:quote_id])
    end
  end
end

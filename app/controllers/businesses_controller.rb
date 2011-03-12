class BusinessesController < ApplicationController
  before_filter :authenticate_user!
  
  respond_to :html
  
  autocomplete_for :business, :name do |businesses|
    businesses.map{|business| "#{business.name} --- #{business.id}"}.join("\n")
  end

  autocomplete_for :bidder, :name, :scope => Business.where(:bidder => true), :class => Business do |businesses|
    businesses.map{|business| "#{business.name} --- #{business.id}"}.join("\n")
  end

  
  def index
    respond_with(Business.new)
  end

  def show
    @business = Business.find(params[:id])

    respond_with(@business)
  end

  def new
    @business = Business.new

    respond_with(@business)
  end

  def edit    
    @business = Business.find(params[:id])

    respond_with(@business)
  end

  def create
    @business = Business.new(params[:business])
    flash[:notice] = 'Business was successfully created.' if @business.save
    respond_with(@business)
  end
  
  def update
    @business = Business.find(params[:id])
    flash[:notice] = 'Business was successfully updated.' if @business.update_attributes(params[:business])
    respond_with(@business)
  end

  def destroy
    @business = Business.find(params[:id])
    @business.destroy
    respond_with(@business)
  end
end

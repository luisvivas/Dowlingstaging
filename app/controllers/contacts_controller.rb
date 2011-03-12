class ContactsController < ApplicationController  
  before_filter :authenticate_user!
  
  contact_select_sql = '(SELECT *, (first_name || \' \' || last_name) AS full_name FROM "contacts") AS contacts'
  autocomplete_for :contact, :name, :select => "*", :from => contact_select_sql, :match => [:first_name, :last_name, :full_name], :scope_by => :business_id do |contacts|
    contacts.map{|contact| "#{contact.name} --- #{contact.id}"}.join("\n")
  end

  autocomplete_for :bidder, :name, :select => "*", :from => contact_select_sql, :match => [:first_name, :last_name, :full_name], :scope_by => :business_id, :scope => Contact.where(:bidder => true) do |contacts|
    contacts.map{|contact| "#{contact.name} --- #{contact.id}"}.join("\n")
  end
  
  respond_to :html, :xml  
  def index
    @business = Business.find(params[:business_id]) if params[:business_id].present?
    respond_with(Contact.new)
  end

  def show
    @contact = Contact.find(params[:id])
    respond_with(@contact)
  end

  def new
    @contact = Contact.new({:business_id => params[:business_id]})
    respond_with(@contact)
  end

  def edit
    @contact = Contact.find(params[:id])
    respond_with(@contact)
  end

  def create
    @contact = Contact.new(params[:contact])
    flash[:notice] = 'Contact was successfully created.' if @contact.save
    respond_with(@contact)
  end

  def update
    @contact = Contact.find(params[:id])
    flash[:notice] = 'Contact was successfully updated.' if @contact.update_attributes(params[:contact])
    respond_with(@contact)
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    respond_with(@contact)
  end
  
end
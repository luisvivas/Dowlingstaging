class ProductsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :move_params
  
  respond_to :html, :json
  
  autocomplete_for :product, :name, {:limit => 5} do |products|
    products.map{ |product| 
      categories = product.category.ancestors << product.category
      "#{categories.map{|c| c.name}.join(' -> ')}: #{product.name} --- #{product.id}"
    }.join("\n")
  end
  
  def index
    respond_with(Product.new)
  end

  def show
    @product = Product.find(params[:id])
    respond_with(@product)
  end

  def new
    @product = Product.new
    respond_with(@product)
  end

  def edit
    @product = Product.find(params[:id])
    respond_with(@product)
  end

  def create
    @product = Product.new(params[:product])
    flash[:notice] = 'Product was successfully created.' if @product.save
    respond_with(@product)
  end

  def update
    @product = Product.find(params[:id])
    flash[:notice] = 'Product was successfully updated.' if @product.update_attributes(params[:product])
    respond_with(@product)
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy
    respond_with(@product)
  end
  
  def in_category
    @products = Product.where(:category_id => params[:q])
    # Put in chained select JSON format
    @products = @products.collect {|p| {:id => p.id, :text => p.name, :type => p.type, :grade => p.grade, :finish => p.finish}}
    respond_with(@products, :thwart_action => :show, :thwart_resource => :product)
  end

  def sizes_for_product
    @sizes = ProductSize.where(:product_id => params[:q])
    # Put in chained select JSON format
    @sizes = @sizes.collect {|p| {:id => p.id, :text => p.name, :amount => p.amount}}
    respond_with(@sizes, :thwart_action => :show, :thwart_resource => :product_size)
  end
  
  private

  def move_params
    Product.descendants.collect{|c| c.table_name.singularize.intern }.each do |p|
      params[:product] = params[p] if params[:product].blank? && params[p].present?
    end
  end
end

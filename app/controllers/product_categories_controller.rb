class ProductCategoriesController < ApplicationController
  before_filter :authenticate_user!
  before_filter :clean_autocomplete_name, :only => [:autocomplete_for_product_root_category_name, :autocomplete_for_product_sub_category_name]
  respond_to :html, :xml, :json
  
  cat_autocomplete = Proc.new do |cats|
    cats.map{|cat| "#{cat.name_with_parents} --- #{cat.id}"}.join("\n")
  end

  autocomplete_for(:product_root_category, :name, :scope => ProductCategory.where(:ancestors_count => 0), &cat_autocomplete)
  
  s = ProductCategory.scoped.joins('LEFT JOIN (SELECT product_categories.id, (category_parents."name" || \' -> \' || product_categories.name) as "extended_name" FROM "product_categories" LEFT JOIN "product_categories" AS "category_parents" ON category_parents."id" = product_categories."parent_id") AS "full_product_categories" ON "product_categories"."id" = "full_product_categories"."id"').select('product_categories.*, full_product_categories.extended_name').where(:ancestors_count => 1)
  
  autocomplete_for(:product_sub_category, :name, :scope => s, :match => ["name", "extended_name"], &cat_autocomplete)
  
  def index
    @product_categories = ProductCategory.where(:ancestors_count => 0).includes(:children)
    respond_with(@product_categories, :thwart_resource => :product_category)
  end

  def show
    @product_category = ProductCategory.find(params[:id])
    respond_with(@product_category)
  end

  def new
    @product_category = ProductCategory.new
    respond_with(@product_category)
  end

  def edit
    @product_category = ProductCategory.find(params[:id], :include => :children)
    respond_with(@product_category)
  end

  def create
    @product_category = ProductCategory.new(params[:product_category])
    flash[:notice] = 'Product Category was successfully created.' if @product_category.save  
    respond_with(@product_category)
  end

  def update
    @product_category = ProductCategory.find(params[:id], :include => [:parent, :children])
    flash[:notice] = 'Product Category was successfully updated.' if @product_category.update_attributes(params[:product_category])
    respond_with(@product_category)    
  end

  def destroy
    @product_category = ProductCategory.find(params[:id])
    flash[:notice] = 'Product Category was successfully deleted.' if @product_category.destroy
    respond_with(@product_category)
  end
  
  def subcategories
    @categories = ProductCategory.where(:parent_id => params[:q])
    # Put in chained select JSON format
    @categories = @categories.collect {|cat| {:id => cat.id, :text => cat.name}}
    respond_with(@categories, :thwart_resource => :product_cateogry, :thwart_action => :show)
  end
  
  private
  def clean_autocomplete_name
    params[:q] = params[:q].split(/: /)[-1]
    return true
  end
end

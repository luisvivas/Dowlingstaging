module ProductsHelper
  def setup_product(product)
    returning(product) do |p|
      p.sizes.build if p.sizes.blank?
    end
  end
  
  def product_product_category_autocomplete(product)
    name = unless product.category.nil?
				product.category.name_with_parents
			else
				""
		  end
	  text_field_tag :auto_product_category_name, name, 
						:class            => "autocomplete tooltip", 
						:autocomplete_url => autocomplete_for_product_sub_category_name_product_categories_path, 
						:data_update      => '#product_category_id',
						:title            => 'Enter the name of a product category to file this product in it.'
  end
  
  def product_quicksearch
		text_field_tag :product_quicksearch, "Product Quicksearch",
						:class							=> "autocomplete quicksearch", 
						:autocomplete_url		=> autocomplete_for_product_name_products_path, 
						:success_url				=> products_path
	end
	
	def product_index_grid
	  self.format_product_grid!
	  Product.grid
	end
	
	def products_in_category_grid
	  self.format_product_in_category!
	  Product.grids[:in_category]
	end
	
	def format_product_grid!
	  self.format_a_product_grid!(Product.grid)
	end
	
	def format_product_in_category!
	  self.format_a_product_grid!(Product.grids[:in_category])
    Product.grids[:in_category].update({
      :name => :in_category,
      :title => "Products in #{@product_category ? @product_category.name_with_parents : "Category" }",
      :url => product_category_products_path(@product_category)
    })
	end
	
	def format_a_product_grid!(which_grid)
	  which_grid.update({
		:title => "Products",
		:pager => true,
		:search_toolbar => :hidden,
		:resizable => false,
		:height => :auto,
		:rows_per_page => 10}) { |grid|
			grid.column :name, :width => 100, :proc => lambda {|product| link_to product.name, product_path(product)}
			grid.column :category, :width => 150, :proc => lambda {|product| link_to product.category.name_with_parents, product_category_path(product.category)}
			grid.column :category_id, :hidden => true
#			grid.column :sizes, :width => 250
			grid.column :notes, :hidden => true
			grid.column :type, :hidden => true
			grid.column :grade, :hidden => true
			grid.column :finish, :hidden => true
			grid.column :created_at, :hidden => true
			grid.column :updated_at, :hidden => true
			grid.column :actions, :sortable => false, :searchable => false, :proc => lambda {|record| 
        permissioned_actions(record) do |p|
      		p.show_link
      		p.link('Show '+record.category.name_with_parents, product_category_path(record.category), :show)
      		p.edit_link
  			  p.destroy_link
        end
			}
		}
	end	
end
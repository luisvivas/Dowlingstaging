module ProductCategoriesHelper
  def product_category_parent_autocomplete(product_cat)
    name = if product_cat.nil? || product_cat.root?
        ""
			else
				product_cat.ancestors.map{|c| c.name}.join(' -> ')
		  end
	  text_field_tag :auto_product_category_name, name, 
						:class            => "autocomplete tooltip", 
						:autocomplete_url => autocomplete_for_product_root_category_name_product_categories_path, 
						:data_update      => '#product_category_parent_id',
						:title            => "Enter the name of another product category to make this product category a subordinate of the one entered above. If you don't enter a parent category, this category will be a top level category which other categories can be subordinate to."
  end
end

require 'spec_helper'

describe "product_categories/edit.html.erb" do
  before(:each) do
    assign(:product_category, @product_category = stub_model(ProductCategory,
      :new_record? => false,
      :name => "MyString",
      :parent_id => 1
    ))
  end

  it "renders the edit product_category form" do
    render

    response.should have_selector("form", :action => product_category_path(@product_category), :method => "post") do |form|
      form.should have_selector("input#product_category_name", :name => "product_category[name]")
      form.should have_selector("input#product_category_parent_id", :name => "product_category[parent_id]")
    end
  end
end

require 'spec_helper'

describe "products/edit.html.erb" do
  before(:each) do
    assign(:product, @product = stub_model(Product,
      :new_record? => false,
      :name => "MyString",
      :category_id => 1,
      :notes => "MyText"
    ))
  end

  it "renders the edit product form" do
    render

    response.should have_selector("form", :action => product_path(@product), :method => "post") do |form|
      form.should have_selector("input#product_name", :name => "product[name]")
      form.should have_selector("input#product_category_id", :name => "product[category_id]")
      form.should have_selector("textarea#product_notes", :name => "product[notes]")
    end
  end
end

require 'spec_helper'

describe "product_categories/index.html.erb" do
  before(:each) do
    assign(:product_categories, [
      stub_model(ProductCategory,
        :name => "MyString",
        :parent_id => 1
      ),
      stub_model(ProductCategory,
        :name => "MyString",
        :parent_id => 1
      )
    ])
  end

  it "renders a list of product_categories" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => 1.to_s, :count => 2)
  end
end

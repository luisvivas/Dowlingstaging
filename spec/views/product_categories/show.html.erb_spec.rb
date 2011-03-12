require 'spec_helper'

describe "product_categories/show.html.erb" do
  before(:each) do
    assign(:product_category, @product_category = stub_model(ProductCategory,
      :name => "MyString",
      :parent_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain(1)
  end
end

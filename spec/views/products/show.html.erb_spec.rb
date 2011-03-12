require 'spec_helper'

describe "products/show.html.erb" do
  before(:each) do
    assign(:product, @product = stub_model(Product,
      :name => "MyString",
      :category_id => 1,
      :notes => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain(1)
    response.should contain("MyText")
  end
end

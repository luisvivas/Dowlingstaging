require 'spec_helper'

describe "products/index.html.erb" do
  before(:each) do
    assign(:products, [
      stub_model(Product,
        :name => "MyString",
        :category_id => 1,
        :notes => "MyText"
      ),
      stub_model(Product,
        :name => "MyString",
        :category_id => 1,
        :notes => "MyText"
      )
    ])
  end

  it "renders a list of products" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyText".to_s, :count => 2)
  end
end

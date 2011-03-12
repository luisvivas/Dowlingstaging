require 'spec_helper'

describe "scope_items/show.html.erb" do
  before(:each) do
    assign(:scope_item, @scope_item = stub_model(ScopeItem,
      :scope_of_work_id => 1,
      :name => "MyString"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain(1)
    response.should contain("MyString")
  end
end

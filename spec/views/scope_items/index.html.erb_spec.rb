require 'spec_helper'

describe "scope_items/index.html.erb" do
  before(:each) do
    assign(:scope_items, [
      stub_model(ScopeItem,
        :scope_of_work_id => 1,
        :name => "MyString"
      ),
      stub_model(ScopeItem,
        :scope_of_work_id => 1,
        :name => "MyString"
      )
    ])
  end

  it "renders a list of scope_items" do
    render
    response.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
  end
end

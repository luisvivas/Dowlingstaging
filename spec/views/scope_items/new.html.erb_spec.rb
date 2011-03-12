require 'spec_helper'

describe "scope_items/new.html.erb" do
  before(:each) do
    assign(:scope_item, stub_model(ScopeItem,
      :new_record? => true,
      :scope_of_work_id => 1,
      :name => "MyString"
    ))
  end

  it "renders new scope_item form" do
    render

    response.should have_selector("form", :action => scope_items_path, :method => "post") do |form|
      form.should have_selector("input#scope_item_scope_of_work_id", :name => "scope_item[scope_of_work_id]")
      form.should have_selector("input#scope_item_name", :name => "scope_item[name]")
    end
  end
end

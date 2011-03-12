require 'spec_helper'

describe "work_orders/edit.html.erb" do
  before(:each) do
    @work_order = assign(:work_order, stub_model(WorkOrder,
      :new_record? => false,
      :quote_id => 1,
      :po_number => "MyString"
    ))
  end

  it "renders the edit work_order form" do
    render

    rendered.should have_selector("form", :action => work_order_path(@work_order), :method => "post") do |form|
      form.should have_selector("input#work_order_quote_id", :name => "work_order[quote_id]")
      form.should have_selector("input#work_order_po_number", :name => "work_order[po_number]")
    end
  end
end

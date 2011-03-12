require 'spec_helper'

describe "work_orders/new.html.erb" do
  before(:each) do
    assign(:work_order, stub_model(WorkOrder,
      :new_record? => true,
      :quote_id => 1,
      :po_number => "MyString"
    ))
  end

  it "renders new work_order form" do
    render

    rendered.should have_selector("form", :action => work_orders_path, :method => "post") do |form|
      form.should have_selector("input#work_order_quote_id", :name => "work_order[quote_id]")
      form.should have_selector("input#work_order_po_number", :name => "work_order[po_number]")
    end
  end
end

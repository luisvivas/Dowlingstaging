require 'spec_helper'

describe "work_orders/index.html.erb" do
  before(:each) do
    assign(:work_orders, [
      stub_model(WorkOrder,
        :quote_id => 1,
        :po_number => "Po Number"
      ),
      stub_model(WorkOrder,
        :quote_id => 1,
        :po_number => "Po Number"
      )
    ])
  end

  it "renders a list of work_orders" do
    render
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Po Number".to_s, :count => 2)
  end
end

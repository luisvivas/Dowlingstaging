require 'spec_helper'

describe "work_orders/show.html.erb" do
  before(:each) do
    @work_order = assign(:work_order, stub_model(WorkOrder,
      :quote_id => 1,
      :po_number => "Po Number"
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain(1.to_s)
    rendered.should contain("Po Number".to_s)
  end
end

require 'spec_helper'

describe "request_for_quotes/index.html.erb" do
  before(:each) do
    assign(:request_for_quotes, [
      stub_model(RequestForQuote,
        :job_name => "MyString",
        :category => "MyString",
        :shred => false,
        :notes => "MyText"
      ),
      stub_model(RequestForQuote,
        :job_name => "MyString",
        :category => "MyString",
        :shred => false,
        :notes => "MyText"
      )
    ])
  end

  it "renders a list of request_for_quotes" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => false.to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyText".to_s, :count => 2)
  end
end

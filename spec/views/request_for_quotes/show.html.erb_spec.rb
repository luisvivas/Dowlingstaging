require 'spec_helper'

describe "request_for_quotes/show.html.erb" do
  before(:each) do
    assign(:request_for_quote, @request_for_quote = stub_model(RequestForQuote,
      :job_name => "MyString",
      :category => "MyString",
      :shred => false,
      :notes => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain(false)
    response.should contain("MyText")
  end
end

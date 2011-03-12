require 'spec_helper'

describe "request_for_quotes/new.html.erb" do
  before(:each) do
    assign(:request_for_quote, stub_model(RequestForQuote,
      :new_record? => true,
      :job_name => "MyString",
      :category => "MyString",
      :shred => false,
      :notes => "MyText"
    ))
  end

  it "renders new request_for_quote form" do
    render

    response.should have_selector("form", :action => request_for_quotes_path, :method => "post") do |form|
      form.should have_selector("input#request_for_quote_job_name", :name => "request_for_quote[job_name]")
      form.should have_selector("input#request_for_quote_category", :name => "request_for_quote[category]")
      form.should have_selector("input#request_for_quote_shred", :name => "request_for_quote[shred]")
      form.should have_selector("textarea#request_for_quote_notes", :name => "request_for_quote[notes]")
    end
  end
end

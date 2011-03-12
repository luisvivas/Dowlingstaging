require 'spec_helper'

describe "quotes/edit.html.erb" do
  before(:each) do
    assign(:quote, @quote = stub_model(Quote,
      :new_record? => false,
      :contact_id => 1,
      :job_name => "MyString",
      :notes => "MyText",
      :shred => false
    ))
  end

  it "renders the edit quote form" do
    render

    rendered.should have_selector("form", :action => quote_path(@quote), :method => "post") do |form|
      form.should have_selector("input#quote_contact_id", :name => "quote[contact_id]")
      form.should have_selector("input#quote_job_name", :name => "quote[job_name]")
      form.should have_selector("textarea#quote_notes", :name => "quote[notes]")
      form.should have_selector("input#quote_shred", :name => "quote[shred]")
    end
  end
end

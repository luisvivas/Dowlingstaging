require 'spec_helper'

describe "correspondences/new.html.erb" do
  before(:each) do
    assign(:correspondence, stub_model(Correspondence,
      :new_record? => true,
      :to => "MyString",
      :from => "MyString",
      :subject => "MyString",
      :body => "MyText",
      :attachments => 1
    ))
  end

  it "renders new correspondence form" do
    render

    rendered.should have_selector("form", :action => correspondences_path, :method => "post") do |form|
      form.should have_selector("input#correspondence_to", :name => "correspondence[to]")
      form.should have_selector("input#correspondence_from", :name => "correspondence[from]")
      form.should have_selector("input#correspondence_subject", :name => "correspondence[subject]")
      form.should have_selector("textarea#correspondence_body", :name => "correspondence[body]")
      form.should have_selector("input#correspondence_attachments", :name => "correspondence[attachments]")
    end
  end
end

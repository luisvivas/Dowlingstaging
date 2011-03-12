require 'spec_helper'

describe "correspondences/index.html.erb" do
  before(:each) do
    assign(:correspondences, [
      stub_model(Correspondence,
        :to => "To",
        :from => "From",
        :subject => "Subject",
        :body => "MyText",
        :attachments => 1
      ),
      stub_model(Correspondence,
        :to => "To",
        :from => "From",
        :subject => "Subject",
        :body => "MyText",
        :attachments => 1
      )
    ])
  end

  it "renders a list of correspondences" do
    render
    rendered.should have_selector("tr>td", :content => "To".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "From".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "Subject".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "MyText".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
  end
end

require 'spec_helper'

describe "correspondences/show.html.erb" do
  before(:each) do
    @correspondence = assign(:correspondence, stub_model(Correspondence,
      :to => "To",
      :from => "From",
      :subject => "Subject",
      :body => "MyText",
      :attachments => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    rendered.should contain("To".to_s)
    rendered.should contain("From".to_s)
    rendered.should contain("Subject".to_s)
    rendered.should contain("MyText".to_s)
    rendered.should contain(1.to_s)
  end
end

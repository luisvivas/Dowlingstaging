require 'spec_helper'

describe "quotes/show.html.erb" do
  before(:each) do
    assign(:quote, @quote = stub_model(Quote,
      :contact_id => 1,
      :job_name => "MyString",
      :notes => "MyText",
      :shred => false
    ))
  end

  it "renders attributes in <p>" do
    render
   rendered.should contain(1)
   rendered.should contain("MyString")
   rendered.should contain("MyText")
   rendered.should contain(false)
  end
end

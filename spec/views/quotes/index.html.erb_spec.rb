require 'spec_helper'

describe "quotes/index.html.erb" do
  before(:each) do
    assign(:quotes, [
      stub_model(Quote,
        :contact_id => 1,
        :job_name => "MyString",
        :notes => "MyText",
        :shred => false
      ),
      stub_model(Quote,
        :contact_id => 1,
        :job_name => "MyString",
        :notes => "MyText",
        :shred => false
      )
    ])
  end

  it "renders a list of quotes" do
    render
    rendered.should have_selector("tr>td", :content => 1.to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => "MyText".to_s, :count => 2)
    rendered.should have_selector("tr>td", :content => false.to_s, :count => 2)
  end
end

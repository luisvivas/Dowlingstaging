require 'spec_helper'

describe "users/index.html.erb" do
  before(:each) do
    assign(:users, [
      stub_model(User,
        :first_name => "MyString",
        :last_name => "MyString",
        :email => "MyString",
        :employee_number => "MyString",
        :home_phone => "MyString",
        :cell_phone => "MyString",
        :address_id => 1
      ),
      stub_model(User,
        :first_name => "MyString",
        :last_name => "MyString",
        :email => "MyString",
        :employee_number => "MyString",
        :home_phone => "MyString",
        :cell_phone => "MyString",
        :address_id => 1
      )
    ])
  end

  it "renders a list of users" do
    render
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => "MyString".to_s, :count => 2)
    response.should have_selector("tr>td", :content => 1.to_s, :count => 2)
  end
end

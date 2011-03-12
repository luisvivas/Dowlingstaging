require 'spec_helper'

describe "users/show.html.erb" do
  before(:each) do
    assign(:user, @user = stub_model(User,
      :first_name => "MyString",
      :last_name => "MyString",
      :email => "MyString",
      :employee_number => "MyString",
      :home_phone => "MyString",
      :cell_phone => "MyString",
      :address_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain("MyString")
    response.should contain(1)
  end
end

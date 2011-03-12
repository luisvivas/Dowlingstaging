require 'spec_helper'

describe "users/new.html.erb" do
  before(:each) do
    assign(:user, stub_model(User,
      :new_record? => true,
      :first_name => "MyString",
      :last_name => "MyString",
      :email => "MyString",
      :employee_number => "MyString",
      :home_phone => "MyString",
      :cell_phone => "MyString",
      :address_id => 1
    ))
  end

  it "renders new user form" do
    render

    response.should have_selector("form", :action => users_path, :method => "post") do |form|
      form.should have_selector("input#user_first_name", :name => "user[first_name]")
      form.should have_selector("input#user_last_name", :name => "user[last_name]")
      form.should have_selector("input#user_email", :name => "user[email]")
      form.should have_selector("input#user_employee_number", :name => "user[employee_number]")
      form.should have_selector("input#user_home_phone", :name => "user[home_phone]")
      form.should have_selector("input#user_cell_phone", :name => "user[cell_phone]")
      form.should have_selector("input#user_address_id", :name => "user[address_id]")
    end
  end
end

require 'spec_helper'
require 'pp'

describe "Permissions System" do
  before do 
    Thwart.log_query_path = true
  end
  context "employee permissions" do
    before do
      @employee = User.new(:role => "employee")
    end
    it "should allow read on RFQs" do
      @employee.can_show?(RequestForQuote.new)
      @employee.can_show?(:request_for_quote)
      pp Thwart.last_query_path
    end
  end
end
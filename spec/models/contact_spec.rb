require 'spec_helper'

describe Contact, :focus => true do
  
  before(:all) do
    puts subject.class
  end
  
  it_should_behave_like "gridified models"
  it_should_behave_like "formatted phone number models"
end

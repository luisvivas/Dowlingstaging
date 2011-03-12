require 'spec_helper'

describe ContactsController do
  # render_views
  # it_should_behave_like "gridified controllers"
  it "should respond with xml to grid queries" do
    get :index, {:grid => "grid"}
    response.should be_success
#    response.should have_tag('contacts', nil, :xml => true, :strict => true)
#    response.should include_text('<?xml version="1.0" encoding="UTF-8"?>')
  end

  it "should respond with xml to grid queries" do
    get :index, {:grid => "grid"}
    response.should have_tag('contacts')
#    response.should include_text('<?xml version="1.0" encoding="UTF-8"?>')
  end
end

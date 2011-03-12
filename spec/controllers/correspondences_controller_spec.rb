require 'spec_helper'

describe CorrespondencesController do
  include Devise::TestHelpers
  
  def mock_correspondence(stubs={})
    @mock_correspondence ||= mock_model(Correspondence, stubs).as_null_object
  end
  
  before(:all) do
#    sign_in Factory.create(:user)
  end
  
  describe "GET index" do
    it "assigns all correspondences as @correspondences" do
      Correspondence.stub(:all) { [mock_correspondence] }
      get :index
      assigns(:correspondences).should eq([mock_correspondence])
    end
  end

  describe "GET show" do
    it "assigns the requested correspondence as @correspondence" do
      Correspondence.stub(:find).with("37") { mock_correspondence }
      get :show, :id => "37"
      assigns(:correspondence).should be(mock_correspondence)
    end
  end

  describe "POST create" do    
    describe "with valid params" do
      it "cleans the params, assigns a newly created correspondence as @correspondence and reports success" do
        attributes = Factory.attributes_for(:correspondence)
        Correspondence.stub(:new).with(attributes) { mock_correspondence(:save => true) }   
        # Intentionally not in the :correspondence namespace of the hash, as if it were coming from sendgrid
        post :create, attributes.merge({:bleh => "blah", :foo => "bar"})
        assigns(:correspondence).should be(mock_correspondence)
        response.should be_success
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved correspondence as @correspondence and reports success" do
        Correspondence.stub(:new).with({'these' => 'params'}) { mock_correspondence(:save => false) }
        post :create, :correspondence => {'these' => 'params'}
        assigns(:correspondence).should be(mock_correspondence)
        response.should be_success        
      end
    end
    
  end

  describe "DELETE destroy" do
    it "destroys the requested correspondence" do
      Correspondence.should_receive(:find).with("37") { mock_correspondence }
      mock_correspondence.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the correspondences list" do
      Correspondence.stub(:find) { mock_correspondence }
      delete :destroy, :id => "1"
      response.should redirect_to(correspondences_url)
    end
  end

end

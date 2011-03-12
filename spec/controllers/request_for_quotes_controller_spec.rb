require 'spec_helper'

describe RequestForQuotesController do

  def mock_request_for_quote(stubs={})
    @mock_request_for_quote ||= mock_model(RequestForQuote, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all request_for_quotes as @request_for_quotes" do
      RequestForQuote.stub(:all) { [mock_request_for_quote] }
      get :index
      assigns(:request_for_quotes).should eq([mock_request_for_quote])
    end
  end

  describe "GET show" do
    it "assigns the requested request_for_quote as @request_for_quote" do
      RequestForQuote.stub(:find).with("37") { mock_request_for_quote }
      get :show, :id => "37"
      assigns(:request_for_quote).should be(mock_request_for_quote)
    end
  end

  describe "GET new" do
    it "assigns a new request_for_quote as @request_for_quote" do
      RequestForQuote.stub(:new) { mock_request_for_quote }
      get :new
      assigns(:request_for_quote).should be(mock_request_for_quote)
    end
  end

  describe "GET edit" do
    it "assigns the requested request_for_quote as @request_for_quote" do
      RequestForQuote.stub(:find).with("37") { mock_request_for_quote }
      get :edit, :id => "37"
      assigns(:request_for_quote).should be(mock_request_for_quote)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created request_for_quote as @request_for_quote" do
        RequestForQuote.stub(:new).with({'these' => 'params'}) { mock_request_for_quote(:save => true) }
        post :create, :request_for_quote => {'these' => 'params'}
        assigns(:request_for_quote).should be(mock_request_for_quote)
      end

      it "redirects to the created request_for_quote" do
        RequestForQuote.stub(:new) { mock_request_for_quote(:save => true) }
        post :create, :request_for_quote => {}
        response.should redirect_to(request_for_quote_url(mock_request_for_quote))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved request_for_quote as @request_for_quote" do
        RequestForQuote.stub(:new).with({'these' => 'params'}) { mock_request_for_quote(:save => false) }
        post :create, :request_for_quote => {'these' => 'params'}
        assigns(:request_for_quote).should be(mock_request_for_quote)
      end

      it "re-renders the 'new' template" do
        RequestForQuote.stub(:new) { mock_request_for_quote(:save => false) }
        post :create, :request_for_quote => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested request_for_quote" do
        RequestForQuote.should_receive(:find).with("37") { mock_request_for_quote }
        mock_request_for_quote.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :request_for_quote => {'these' => 'params'}
      end

      it "assigns the requested request_for_quote as @request_for_quote" do
        RequestForQuote.stub(:find) { mock_request_for_quote(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:request_for_quote).should be(mock_request_for_quote)
      end

      it "redirects to the request_for_quote" do
        RequestForQuote.stub(:find) { mock_request_for_quote(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(request_for_quote_url(mock_request_for_quote))
      end
    end

    describe "with invalid params" do
      it "assigns the request_for_quote as @request_for_quote" do
        RequestForQuote.stub(:find) { mock_request_for_quote(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:request_for_quote).should be(mock_request_for_quote)
      end

      it "re-renders the 'edit' template" do
        RequestForQuote.stub(:find) { mock_request_for_quote(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested request_for_quote" do
      RequestForQuote.should_receive(:find).with("37") { mock_request_for_quote }
      mock_request_for_quote.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the request_for_quotes list" do
      RequestForQuote.stub(:find) { mock_request_for_quote(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(request_for_quotes_url)
    end
  end

end

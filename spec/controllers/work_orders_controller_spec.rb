require 'spec_helper'

describe WorkOrdersController do

  def mock_work_order(stubs={})
    @mock_work_order ||= mock_model(WorkOrder, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all work_orders as @work_orders" do
      WorkOrder.stub(:all) { [mock_work_order] }
      get :index
      assigns(:work_orders).should eq([mock_work_order])
    end
  end

  describe "GET show" do
    it "assigns the requested work_order as @work_order" do
      WorkOrder.stub(:find).with("37") { mock_work_order }
      get :show, :id => "37"
      assigns(:work_order).should be(mock_work_order)
    end
  end

  describe "GET new" do
    it "assigns a new work_order as @work_order" do
      WorkOrder.stub(:new) { mock_work_order }
      get :new
      assigns(:work_order).should be(mock_work_order)
    end
  end

  describe "GET edit" do
    it "assigns the requested work_order as @work_order" do
      WorkOrder.stub(:find).with("37") { mock_work_order }
      get :edit, :id => "37"
      assigns(:work_order).should be(mock_work_order)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created work_order as @work_order" do
        WorkOrder.stub(:new).with({'these' => 'params'}) { mock_work_order(:save => true) }
        post :create, :work_order => {'these' => 'params'}
        assigns(:work_order).should be(mock_work_order)
      end

      it "redirects to the created work_order" do
        WorkOrder.stub(:new) { mock_work_order(:save => true) }
        post :create, :work_order => {}
        response.should redirect_to(work_order_url(mock_work_order))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved work_order as @work_order" do
        WorkOrder.stub(:new).with({'these' => 'params'}) { mock_work_order(:save => false) }
        post :create, :work_order => {'these' => 'params'}
        assigns(:work_order).should be(mock_work_order)
      end

      it "re-renders the 'new' template" do
        WorkOrder.stub(:new) { mock_work_order(:save => false) }
        post :create, :work_order => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested work_order" do
        WorkOrder.should_receive(:find).with("37") { mock_work_order }
        mock_work_order.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :work_order => {'these' => 'params'}
      end

      it "assigns the requested work_order as @work_order" do
        WorkOrder.stub(:find) { mock_work_order(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:work_order).should be(mock_work_order)
      end

      it "redirects to the work_order" do
        WorkOrder.stub(:find) { mock_work_order(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(work_order_url(mock_work_order))
      end
    end

    describe "with invalid params" do
      it "assigns the work_order as @work_order" do
        WorkOrder.stub(:find) { mock_work_order(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:work_order).should be(mock_work_order)
      end

      it "re-renders the 'edit' template" do
        WorkOrder.stub(:find) { mock_work_order(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested work_order" do
      WorkOrder.should_receive(:find).with("37") { mock_work_order }
      mock_work_order.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the work_orders list" do
      WorkOrder.stub(:find) { mock_work_order }
      delete :destroy, :id => "1"
      response.should redirect_to(work_orders_url)
    end
  end

end

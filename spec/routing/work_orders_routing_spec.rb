require "spec_helper"

describe WorkOrdersController do
  describe "routing" do

        it "recognizes and generates #index" do
      { :get => "/work_orders" }.should route_to(:controller => "work_orders", :action => "index")
    end

        it "recognizes and generates #new" do
      { :get => "/work_orders/new" }.should route_to(:controller => "work_orders", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/work_orders/1" }.should route_to(:controller => "work_orders", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/work_orders/1/edit" }.should route_to(:controller => "work_orders", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/work_orders" }.should route_to(:controller => "work_orders", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/work_orders/1" }.should route_to(:controller => "work_orders", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/work_orders/1" }.should route_to(:controller => "work_orders", :action => "destroy", :id => "1") 
    end

  end
end

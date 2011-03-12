require "spec_helper"

describe CorrespondencesController do
  describe "routing" do

        it "recognizes and generates #index" do
      { :get => "/correspondences" }.should route_to(:controller => "correspondences", :action => "index")
    end

        it "recognizes and generates #new" do
      { :get => "/correspondences/new" }.should route_to(:controller => "correspondences", :action => "new")
    end

    it "recognizes and generates #show" do
      { :get => "/correspondences/1" }.should route_to(:controller => "correspondences", :action => "show", :id => "1")
    end

    it "recognizes and generates #edit" do
      { :get => "/correspondences/1/edit" }.should route_to(:controller => "correspondences", :action => "edit", :id => "1")
    end

    it "recognizes and generates #create" do
      { :post => "/correspondences" }.should route_to(:controller => "correspondences", :action => "create") 
    end

    it "recognizes and generates #update" do
      { :put => "/correspondences/1" }.should route_to(:controller => "correspondences", :action => "update", :id => "1") 
    end

    it "recognizes and generates #destroy" do
      { :delete => "/correspondences/1" }.should route_to(:controller => "correspondences", :action => "destroy", :id => "1") 
    end

  end
end

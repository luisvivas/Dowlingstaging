require 'spec_helper'

describe ProductCategoriesController do

  def mock_product_category(stubs={})
    @mock_product_category ||= mock_model(ProductCategory, stubs).as_null_object
  end

  describe "GET index" do
    it "assigns all product_categories as @product_categories" do
      ProductCategory.stub(:all) { [mock_product_category] }
      get :index
      assigns(:product_categories).should eq([mock_product_category])
    end
  end

  describe "GET show" do
    it "assigns the requested product_category as @product_category" do
      ProductCategory.stub(:find).with("37") { mock_product_category }
      get :show, :id => "37"
      assigns(:product_category).should be(mock_product_category)
    end
  end

  describe "GET new" do
    it "assigns a new product_category as @product_category" do
      ProductCategory.stub(:new) { mock_product_category }
      get :new
      assigns(:product_category).should be(mock_product_category)
    end
  end

  describe "GET edit" do
    it "assigns the requested product_category as @product_category" do
      ProductCategory.stub(:find).with("37") { mock_product_category }
      get :edit, :id => "37"
      assigns(:product_category).should be(mock_product_category)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created product_category as @product_category" do
        ProductCategory.stub(:new).with({'these' => 'params'}) { mock_product_category(:save => true) }
        post :create, :product_category => {'these' => 'params'}
        assigns(:product_category).should be(mock_product_category)
      end

      it "redirects to the created product_category" do
        ProductCategory.stub(:new) { mock_product_category(:save => true) }
        post :create, :product_category => {}
        response.should redirect_to(product_category_url(mock_product_category))
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved product_category as @product_category" do
        ProductCategory.stub(:new).with({'these' => 'params'}) { mock_product_category(:save => false) }
        post :create, :product_category => {'these' => 'params'}
        assigns(:product_category).should be(mock_product_category)
      end

      it "re-renders the 'new' template" do
        ProductCategory.stub(:new) { mock_product_category(:save => false) }
        post :create, :product_category => {}
        response.should render_template("new")
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested product_category" do
        ProductCategory.should_receive(:find).with("37") { mock_product_category }
        mock_product_category.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :product_category => {'these' => 'params'}
      end

      it "assigns the requested product_category as @product_category" do
        ProductCategory.stub(:find) { mock_product_category(:update_attributes => true) }
        put :update, :id => "1"
        assigns(:product_category).should be(mock_product_category)
      end

      it "redirects to the product_category" do
        ProductCategory.stub(:find) { mock_product_category(:update_attributes => true) }
        put :update, :id => "1"
        response.should redirect_to(product_category_url(mock_product_category))
      end
    end

    describe "with invalid params" do
      it "assigns the product_category as @product_category" do
        ProductCategory.stub(:find) { mock_product_category(:update_attributes => false) }
        put :update, :id => "1"
        assigns(:product_category).should be(mock_product_category)
      end

      it "re-renders the 'edit' template" do
        ProductCategory.stub(:find) { mock_product_category(:update_attributes => false) }
        put :update, :id => "1"
        response.should render_template("edit")
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested product_category" do
      ProductCategory.should_receive(:find).with("37") { mock_product_category }
      mock_product_category.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "redirects to the product_categories list" do
      ProductCategory.stub(:find) { mock_product_category(:destroy => true) }
      delete :destroy, :id => "1"
      response.should redirect_to(product_categories_url)
    end
  end

end

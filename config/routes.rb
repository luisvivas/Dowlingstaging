Dowling::Application.routes.draw do |map|

  # User Management
  devise_for :users

  resources :users do
    get :index, :on => :collection, :as => :root
  end

  # Contact Manager
  resources :businesses do
    collection do
      get :autocomplete_for_bidder_name
      get :autocomplete_for_business_name
    end
    resources :contacts
  end
  resources :states, :only => [:index]

  resources :contacts do
    collection do
      get :autocomplete_for_contact_name
      get :autocomplete_for_bidder_name
    end
  end

  # Product Manager
  resources :products do
    get :autocomplete_for_product_name, :on => :collection
    get :in_category, :on => :collection
    get :sizes_for_product, :on => :collection
  end

  resources :sheet_products, :controller => "products"
  resources :length_products, :controller => "products"
  resources :unit_products, :controller => "products"

  resources :product_categories do
    collection do
      get :autocomplete_for_product_root_category_name
      get :autocomplete_for_product_sub_category_name
      get :subcategories
    end
    resources :products
  end

  # RFQ Manager
  resources :request_for_quotes do
    get :autocomplete_for_request_for_quote_job_name, :on => :collection
    get :queue, :on => :collection
    resources :scope_of_works, :only => [:new, :create, :destroy] do
      member do
        get :generate_quote
        get :generate_new_quote
        get :duplicate_quote
        get :lead_letter
      end
    end
    resources :job_resources, :only => [:index, :new, :create]
    resources :correspondences, :only => [:index, :show]
  end
  resources :scope_of_works, :only => [:show]

  # Quote Manager
  resources :quotes do
    member do
      get :generate_work_order
      get :printable
    end
    collection do
      get :autocomplete_for_quote_job_name
      get :queue
    end
    resources :job_resources, :only => [:index, :new, :create]
    resources :correspondences, :only => [:index, :show, :destroy]
  end

  # Work Orders
  resources :work_orders do
    get :printable, :on => :member
    collection do      
      get :autocomplete_for_work_order_name
      get :queue
      get :quote_items
    end
    
    resources :end_of_day_reports, :only => [:show]
    resources :correspondences, :only => [:index, :show]
  end
  # End of day Report
  resource :end_of_day_report, :only => [:new, :create]
  resources :job_resources, :only => [:destroy]

  # Discussable Correspondence routes
  match '/correspondences/secret_create_739d61519d6df1aedce54beb35623c6' => 'correspondences#create'
  resources :correspondences, :only => [:destroy]

  # Report Viewer
  match '/reports/:action', :controller => :reports, :as => :reports
  match '/reports/(:id/:action)', :controller => :reports, :as => :reports

  # Dashboard settings and root
  match '/admin/settings' => 'dashboard#settings', :as => :settings

  root :to => "dashboard#index"


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

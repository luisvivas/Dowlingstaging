Thwart.configure do
  default_query_response false
  
  action_group :manage, [:show, :create, :update, :destroy]
  action_group :manage_existing, [:show, :update]

  role :everyone do
    show :state, :dashboard
  end
  
  role :employee, :parents => [:everyone] do
    show :address, :business, :contact, :feed_item, :job_resource, :labour_line_item, :product_line_item, :product, :product_category, :product_size
    show :quote, :quote_item, :request_for_quote, :scope_item, :scope_of_work, :work_order, :rfq_queue, :work_order_queue
    show :user, :if => Proc.new {|actor, resource, role| actor == resource}
    manage :end_of_day_report
    manage_existing :work_order
  end
  
  role :manager, :parents => [:employee, :everyone] do
    show :all
    show :end_of_day_report_estimates
    manage :end_of_day_report, :request_for_quote, :scope_item, :scope_of_work, :quote, :quote_item, :product_line_item, :labour_line_item, :work_order
  end
  
  role :administrator do
    manage :all
  end
end

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101025224151) do

  create_table "addresses", :force => true do |t|
    t.string   "street1"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "zipcode"
    t.string   "country"
    t.integer  "addressable_id"
    t.string   "addressable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "businesses", :force => true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "telephone"
    t.string   "fax"
    t.string   "email"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "bidder",     :default => false
  end

  create_table "contacts", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "department"
    t.string   "email"
    t.string   "telephone"
    t.string   "mobile"
    t.string   "fax"
    t.integer  "business_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "bidder",      :default => false
  end

  create_table "correspondences", :force => true do |t|
    t.string   "to_name"
    t.string   "to_email"
    t.string   "contact_id"
    t.string   "user_id"
    t.boolean  "outgoing"
    t.string   "from_name"
    t.string   "from_email"
    t.string   "subject"
    t.text     "body"
    t.integer  "attachments"
    t.string   "discussable_type"
    t.integer  "discussable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "end_of_day_reports", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "extra_hours",       :default => 0.0
    t.text     "hours_description"
  end

  create_table "end_of_day_reports_quote_items", :id => false, :force => true do |t|
    t.integer "end_of_day_report_id"
    t.integer "quote_item_id"
  end

  create_table "feed_items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.string   "activity_type"
    t.string   "extra"
    t.boolean  "feed_display"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_resources", :force => true do |t|
    t.integer  "attachable_id"
    t.string   "attachable_type"
    t.string   "name"
    t.string   "category"
    t.string   "resource_file_name"
    t.string   "resource_content_type"
    t.integer  "resource_file_size"
    t.datetime "resource_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "labour_line_items", :force => true do |t|
    t.string   "description"
    t.integer  "workers"
    t.integer  "quote_item_id"
    t.decimal  "setup_time"
    t.decimal  "run_time"
    t.decimal  "hourly_rate"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "markup"
    t.string   "event_id"
    t.datetime "start"
    t.datetime "end"
    t.decimal  "hours_completed"
    t.boolean  "complete",        :default => false
    t.boolean  "scheduled"
    t.boolean  "shop",            :default => true
  end

  create_table "product_based_line_items", :force => true do |t|
    t.integer  "product_id"
    t.integer  "quote_item_id"
    t.integer  "product_size_id"
    t.decimal  "amount_needed"
    t.string   "dimension"
    t.decimal  "order_quantity"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "markup"
    t.decimal  "cost_per_pound"
    t.string   "grade"
    t.string   "finish"
    t.boolean  "ordered",          :default => false
    t.boolean  "in_stock",         :default => false
    t.decimal  "product_consumed"
    t.string   "custom_name"
    t.string   "type"
  end

  create_table "product_categories", :force => true do |t|
    t.string   "name"
    t.integer  "parent_id"
    t.integer  "children_count"
    t.integer  "ancestors_count"
    t.integer  "descendants_count"
    t.boolean  "hidden"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "cost_per_pound"
  end

  create_table "product_sizes", :force => true do |t|
    t.string   "name"
    t.integer  "product_id"
    t.decimal  "retail_price"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "amount"
  end

  create_table "products", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
    t.boolean  "grade"
    t.boolean  "finish"
  end

  create_table "quote_items", :force => true do |t|
    t.integer  "quote_id"
    t.string   "name"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "hardware_markup"
    t.decimal  "markup"
  end

  create_table "quotes", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "scope_of_work_id"
    t.string   "job_name"
    t.text     "notes"
    t.boolean  "shred"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "needs_installation"
    t.integer  "business_id"
    t.integer  "user_id"
    t.decimal  "markup"
    t.datetime "printed_at"
  end

  create_table "request_for_quotes", :force => true do |t|
    t.string   "job_name"
    t.string   "category"
    t.boolean  "shred"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "site_visit"
    t.datetime "due_date"
    t.boolean  "bidding"
    t.boolean  "complete"
  end

  create_table "scope_items", :force => true do |t|
    t.integer  "scope_of_work_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "notes"
  end

  create_table "scope_of_works", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "request_for_quote_id"
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "business_id"
  end

  create_table "settings", :force => true do |t|
    t.string   "var",        :null => false
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["var"], :name => "index_settings_on_var"

  create_table "time_reports", :force => true do |t|
    t.integer  "user_id"
    t.integer  "labour_line_item_id"
    t.integer  "end_of_day_report_id"
    t.decimal  "hours_added"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "description"
  end

  create_table "user_schedules", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "labour_line_item_id"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",               :default => "", :null => false
    t.string   "employee_number"
    t.string   "home_phone"
    t.string   "cell_phone"
    t.integer  "address_id"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  create_table "work_orders", :force => true do |t|
    t.integer  "quote_id"
    t.datetime "due_date"
    t.string   "po_number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "complete",   :default => false
  end

end

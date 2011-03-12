# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :labour_line_item do |f|
  f.workers 1
  f.quote_item_id 1
  f.setup_time "9.99"
  f.run_time "9.99"
  f.hourly_rate "9.99"
end

# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :work_order do |f|
  f.quote_id 1
  f.due_date "2010-07-07 14:21:51"
  f.po_number "MyString"
end

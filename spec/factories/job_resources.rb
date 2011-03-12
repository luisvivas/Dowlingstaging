# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :job_resource do |f|
  f.attachable_id 1
  f.attachable_type "MyString"
  f.name "MyString"
  f.shop_drawing false
end

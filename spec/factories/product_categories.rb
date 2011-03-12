# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :product_category do |f|
  f.name "MyString"
  f.parent_id 1
end

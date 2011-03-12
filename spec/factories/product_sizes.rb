# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :product_size do |f|
  f.name "MyString"
  f.product_id 1
  f.retail_price "9.99"
  f.cost "9.99"
end

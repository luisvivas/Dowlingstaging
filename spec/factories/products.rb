# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :product do |f|
  f.name "MyString"
  f.category_id 1
  f.notes "MyText"
end

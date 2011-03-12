# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :feed_item do |f|
  f.user_id 1
  f.resource_id 1
  f.resource_type "MyString"
  f.extra "MyString"
end

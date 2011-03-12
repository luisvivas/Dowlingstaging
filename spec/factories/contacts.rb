# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :contact do |c|
  c.first_name "John"
  c.last_name "Smith"
  c.association :business
  c.telephone 1234567910
  c.association :address
end

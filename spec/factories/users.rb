# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.first_name "Mary"
  f.last_name "Employee"
  f.email "mary@dowlingmetals.com"
  f.employee_number "12345678"
  f.home_phone "6135554444"
  f.cell_phone "6145554444"
  f.association :address
end

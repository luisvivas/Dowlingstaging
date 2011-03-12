# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :quote do |f|
  f.association :contact
  f.job_name "Job for Queens"
  f.category "Railing"
  f.tax 13
end

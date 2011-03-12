Factory.define :business do |b|
  b.name 'ACME Web Design'
  b.telephone '613510820833'
  b.association :address
end
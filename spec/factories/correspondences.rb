# Read about factories at http://github.com/thoughtbot/factory_girl
Factory.define :correspondence do |f|
  f.to "harry@watch.skylightlabs.ca\n"
  f.from "Harry Brundage <harry.brundage@gmail.com>\n"
  f.subject "An email!\n"
  f.body "asdad\r\n\r\n-- \r\nCheers,\r\nHarry Brundage\n"
  f.attachments 0
end


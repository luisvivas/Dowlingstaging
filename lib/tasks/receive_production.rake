namespace :db do
  task :setup_production => :environment do
    users = []
    users.push User.find_or_create_by_email("demo@skylightlabs.ca")
    users.push User.find_or_create_by_email("harry@skylightlabs.ca")
    users.push User.find_or_create_by_email("admin@dowlingmetal.com")
    users.each do |u|
      u.role = "administrator"
      u.save!
    end
  end
end
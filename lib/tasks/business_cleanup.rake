namespace :clean do

	desc "Decapitalize businesses"
	task :businesses => :environment do
	  Business.all.each do |business|
	    if business.name == business.name.upcase
	      business.name = business.name.titleize.strip
	      business.save!
	    end
	  end
	end
end
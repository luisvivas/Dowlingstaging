
def random_telephone
	(1000000000 + rand(8999999999)).to_s
end

def random_boolean
	(rand(0) > 0.5 ? true : false)
end

class Array
	def random_element
		self[Kernel.rand(length)]
	end
end

def discuss(obj, user, contact)
	5.times do |i|
		Correspondence.create! do |c|
			c.discussable = obj
			c.user = user
			c.contact = contact
			outgoing = random_boolean
			c.outgoing = outgoing
			if outgoing
				c.to_email = contact.email
				c.from_email = user.email
			else
				c.from_email = contact.email
				c.to_email = user.email
			end
			c.subject = %w(Stuff Things Info Questions).random_element + " about #{obj.best_identifier}"
			c.body = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
		end
	end
end

namespace :demo do

	desc "Install demo data"
	task :install => :environment do
		if Rails.env == "development"
			Rake::Task['db:drop'].invoke
			Rake::Task['db:setup'].invoke
		end
		
		puts "Loading Businesses"
		businesses = []
		15.times do
			businesses << Business.create! do |c|
				c.name = %w(ACME National International).random_element + " " + %w(Semiconductor Fabrication Design ).random_element + " " + %w(Inc LLC Co Ltd).random_element
				c.telephone = random_telephone
				c.address = Address.create! do |a|
					a.street1 = rand(999).to_s + " " + %w(Easy Sesame Wall Main).random_element + " " + %w(Street Avenue Boulevard).random_element
					a.city = %w(Kingston Napanee Ottawa Toronto).random_element
					a.zipcode = "A1A 1A1"
					a.state = %w(ON QC BC).random_element
					a.country = "CA"
				end
			end
		end
		
		puts "Loading Contacts"
		contacts = []
		35.times do |i|
		contacts << Contact.create! do |c|
				c.first_name = %w(Harry Jim Joe Fred Larry James Jane Christy Mary).random_element
				c.last_name = %w(Smith Brown Jones James Johnson Arbutus).random_element
				c.email = "#{c.first_name}.#{c.last_name}#{i}@contact.com"
				c.telephone = random_telephone
				c.mobile = random_telephone
				c.fax = random_telephone
				c.address = Address.create! do |a|
					a.street1 = rand(999).to_s + " " +	%w(Easy Sesame Wall Main).random_element + " " + %w(Street Avenue Boulevard).random_element
					a.city = %w(Kingston Napanee Ottawa Toronto).random_element
					a.zipcode = "A1A 1A1"
					a.state = %w(ON QC BC).random_element
					a.country = "CA"
				end
				c.business = businesses.random_element
			end
		end
		
		puts "Loading Users"
		users = []
		10.times do |i|
			users << User.create! do |c|
				c.first_name = %w(Harry Jim Joe Fred Larry James Jane Christy Mary).random_element
				c.last_name = %w(Smith Brown Jones James Johnson Arbutus).random_element
				c.email = "#{c.first_name}.#{c.last_name}#{i}@dowling.com"
				c.address = Address.create! do |a|
					a.street1 = rand(999).to_s + " " +	%w(Easy Sesame Wall Main).random_element + " " + %w(Street Avenue Boulevard).random_element
					a.city = %w(Kingston Napanee Ottawa Toronto).random_element
					a.zipcode = "A1A 1A1"
					a.state = %w(ON QC BC).random_element
					a.country = "CA"
				end
			end
		end
		
		puts "Loading Product Categories"
		cats = ["Aluminum", "Steel", "Stainless Steel", "Copper", "Colored Metal"].inject([]) do |memo, name|
			cat = ProductCategory.create!(:name => name, :cost_per_pound => rand)
			(rand(7)+1).times do |i|
				cat.children.create!(:name => "Gauge #{i}")
			end
			memo << cat
			memo
		end
				
		puts "Loading Products"
		all_products = []
		ProductCategory.where(:descendants_count => 0).each do |cat|	
			(rand(4)+2).times do 
				klass = [SheetProduct, LengthProduct, UnitProduct].random_element
				all_products << klass.create! do |product|
					product.category = cat
					if cat.parent.name == "Stainless Steel"
						product.grade = true
						product.finish = true
					else
						product.grade = false
						product.finish = false
					end
					product.name = %w(C-channel L-channel Sheet Tube Bar Rod ).random_element + " " + rand(999999999).to_s
					sizes = []
					(rand(4)+1).times do |i|
						sizes << ProductSize.create! do |s|
							s.name = "Size #{i}"
							s.amount = ((rand(1000))/700.0)+0.01
						end
					end
					product.sizes = sizes
				end
				
			end
		end
		
		puts "Loading RFQs"
		all_scopes = []
		10.times do 
			rfq = RequestForQuote.create! do |rfq|
				rfq.job_name = %w(Queens City Library Residential Industrial).random_element + " Job #" + rand(999999999).to_s
				rfq.due_date = rand(5).days.from_now.change(:hour => 17)
				rfq.category = %w(Roofing Railing Kitchen Industrial).random_element
				rfq.shred = random_boolean
				rfq.site_visit = random_boolean
				rfq.bidding = true
			end
			scopes = []
			potential_contacts = contacts.sort_by {rand}
			potential_businesses = businesses.sort_by {rand}
			(rand(3)+1).times do |i|
				items = []
				(rand(5)+1).times do |j|
					items << ScopeItem.create! do |s|
						s.name = "Item #{j}"
					end
				end
				scope = rfq.scope_of_works.build do |s|				 
				  if rand > 0.5
					  s.contact = potential_contacts.pop 
					else
					  s.business = potential_businesses.pop
					end
				end
				scope.scope_items = items

				scope.save!
				scopes << scope
			end
			rfq.scope_of_works = scopes
			rand(3).times do
				discuss(rfq, users.random_element, contacts.random_element)
			end
			rfq.save!
			all_scopes += scopes
		end
		
		puts "Loading Quotes"
		all_quotes = []
		quotable_scopes = all_scopes.sort_by {rand}
		(rand(3)).times do 
			scope = quotable_scopes.pop
			quote = scope.to_quote(users.random_element)
			quote.save!
			all_quotes << quote
		end
		(rand(10)+5).times do 
			quote = Quote.create! do |q|
				q.job_name = %w(Queens City Library Residential Industrial).random_element + " Job #" + rand(999999999).to_s
				q.user = users.random_element
				q.category = %w(Roofing Railing Kitchen Industrial Utility HVAC).random_element
				q.shred = random_boolean
				q.needs_installation = random_boolean
				q.contact = contacts.random_element
				if rand > 0.6
				  q.business = q.contact.business if q.contact.business.present?
				end
				q.markup = Settings.quote_markup
			end
			quote.save!
			all_quotes << quote
			(rand(4)+1).times do |j|
				item = quote.quote_items.build do |i|
					i.name = "Item #{j}"
					i.hardware_markup = Settings.quote_item_hardware_markup
					i.markup = Settings.quote_item_markup
				end
				item.save!
				material_products = all_products.sort_by {rand}
				(rand(4)+1).times do
					product = material_products.pop
					item.product_line_items.build do |p|
						p.product_id = product.id
						if product.grade
							p.grade = Product.available_grades.random_element
						end
						if product.finish
							p.finish = Product.available_finishes.random_element
						end
						p.cost_per_pound = product.category.parent.cost_per_pound
						size = product.sizes.random_element
						p.product_size_id = size.id
						amt = rand(50).to_f+1.0
						dim = product.class.available_dimensions.keys.random_element
						p.amount_needed = amt 
						p.dimension = dim
						p.order_quantity = (amt / p.dimension_decimal).ceil
						p.markup = Settings.product_markup
					end
				end
        (rand(5)+1).times do |k|
          item.custom_line_items.build do |l|
            l.custom_name = "Custom Item #{rand(10000)}"
            l.order_quantity = rand(20)
            l.cost_per_pound = rand(1000000)/100.0+0.01
            l.markup = Settings.custom_markup
          end
        end
				(rand(4)+1).times do |k|
					item.labour_line_items.build do |l|
						l.description = "Labour #{k}"
						l.workers = rand(3)+1
						l.setup_time = rand(4)/(rand(3)+1)
						l.run_time = rand(12)/(rand(5)+1)
						l.hourly_rate = Settings.labour_hourly_rate + (rand(5) >= 4 ? rand(10)-5 : 0)
						l.markup = Settings.labour_markup
					end 
				end
				quote.quote_items << item
			end
			rand(3).times do
				discuss(quote, users.random_element, contacts.random_element)
			end
			quote.save!
		end
	 
	  puts "Loading Work Orders"
  	orderable_quotes = all_quotes.sort_by {rand}
    (orderable_quotes - rand(5)).times do |i|
      q = orderable_quotes.pop
      wo = q.to_work_order
      wo.due_date = Time.now - rand(7).days + (rand(i*10) + rand(5)).days
      wo.save!
      q.quote_items.each do |x| 
        x.product_line_items.each do |pli|
          pli.ordered = random_boolean
          pli.in_stock = random_boolean
          pli.product_consumed = rand(pli.order_quantity)
          pli.save!
        end
        x.labour_line_items.each do |lli|
          lli.scheduled = random_boolean
          lli.hours_completed = rand(lli.total_hours)
          lli.save!
        end
      end
    end

	puts "Done loading demo data!" 
	 
	end
end
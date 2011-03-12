module UsersHelper
  def edit_user_title
    if @user == current_user
      "Edit My Profile"
    else
      "Editing #{@user.name}"
    end
  end
  
  def user_index_grid
	  self.format_user_grid!
	  User.grid
	end
	
	def format_user_grid!
    User.grid.update({
		:title => "Users",
		:pager => true,
		:search_toolbar => :hidden,
		:resizable => false,
		:height => :auto,
		:rows_per_page => 10}) { |grid|
			grid.column :first_name, :width => 100, :proc => lambda {|record| link_to record.first_name || "", user_path(record)}
			grid.column :last_name, :width => 100, :proc => lambda {|record| link_to record.last_name || "", user_path(record)}
			grid.column :email, :width => 150, :proc => lambda {|record| mail_to record.email, record.email }
			grid.column :employee_number, :hidden => true
			grid.column :home_phone, :width => 110
			grid.column :mobile_phone, :hidden => true
			grid.column :actions, :sortable => false, :searchable => false, :proc => lambda {|record| 
        permissioned_actions(record) do |p|
      		p.trifecta
        end
			}
    }
	end
end

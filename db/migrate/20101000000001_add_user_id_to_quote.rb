class AddUserIdToQuote < ActiveRecord::Migration
  def self.up
    add_column :quotes, :user_id, :integer
    u = User.first
    Quote.update_all(:user_id => u.id)
  end

  def self.down
    remove_column :quotes, :user_id
  end
end

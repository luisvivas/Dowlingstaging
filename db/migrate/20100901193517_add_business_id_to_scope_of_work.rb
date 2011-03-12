class AddBusinessIdToScopeOfWork < ActiveRecord::Migration
  def self.up
    add_column :scope_of_works, :business_id, :integer
    remove_column :request_for_quotes, :business_id
    
  end

  def self.down
    remove_column :request_for_quotes, :business_id
    add_column :request_for_quotes, :business_id, :integer
  end
end

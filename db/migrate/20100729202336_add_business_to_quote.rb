class AddBusinessToQuote < ActiveRecord::Migration
  def self.up
    add_column :quotes, :business_id, :integer
    add_column :request_for_quotes, :business_id, :integer
    
  end

  def self.down
    remove_column :quotes, :business_id
    remove_column :request_for_quotes, :business_id
  end
end

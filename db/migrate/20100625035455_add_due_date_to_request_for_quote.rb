class AddDueDateToRequestForQuote < ActiveRecord::Migration
  def self.up
    add_column :request_for_quotes, :due_date, :datetime
  end

  def self.down
    remove_column :request_for_quotes, :due_date
  end
end

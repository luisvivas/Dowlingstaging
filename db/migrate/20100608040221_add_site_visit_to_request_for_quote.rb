class AddSiteVisitToRequestForQuote < ActiveRecord::Migration
  def self.up
    add_column :request_for_quotes, :site_visit, :boolean
  end

  def self.down
    remove_column :request_for_quotes, :site_visit
  end
end

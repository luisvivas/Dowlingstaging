class CreateEndOfDayReportsQuoteItemsJoinTable < ActiveRecord::Migration
    def self.up
      create_table :end_of_day_reports_quote_items, :id => false do |t|
        t.integer :end_of_day_report_id
        t.integer :quote_item_id
      end
    end

    def self.down
      drop_table :end_of_day_reports_quote_items
    end
  end
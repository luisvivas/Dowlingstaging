class CreateRequestForQuotes < ActiveRecord::Migration
  def self.up
    create_table :request_for_quotes do |t|
      t.string :job_name
      t.string :category
      t.boolean :shred
      t.text :notes

      t.timestamps
    end
  end

  def self.down
    drop_table :request_for_quotes
  end
end

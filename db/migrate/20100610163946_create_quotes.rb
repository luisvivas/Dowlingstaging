class CreateQuotes < ActiveRecord::Migration
  def self.up
    create_table :quotes do |t|
      t.integer :contact_id
      t.integer :scope_of_work_id
      t.string :job_name
      t.text :notes
      t.boolean :shred
      t.time :printed_at
      t.string :category

      t.timestamps
    end
  end

  def self.down
    drop_table :quotes
  end
end

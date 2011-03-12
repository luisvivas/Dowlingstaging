class CreateWorkOrders < ActiveRecord::Migration
  def self.up
    create_table :work_orders do |t|
      t.integer :quote_id
      t.datetime :due_date
      t.string :po_number

      t.timestamps
    end
  end

  def self.down
    drop_table :work_orders
  end
end

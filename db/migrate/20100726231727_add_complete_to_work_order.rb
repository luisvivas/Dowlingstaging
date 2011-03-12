class AddCompleteToWorkOrder < ActiveRecord::Migration
  def self.up
    add_column :work_orders, :complete, :boolean, :default => false
  end

  def self.down
    remove_column :work_orders, :complete
  end
end

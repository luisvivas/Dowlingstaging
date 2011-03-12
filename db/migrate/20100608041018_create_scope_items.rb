class CreateScopeItems < ActiveRecord::Migration
  def self.up
    create_table :scope_items do |t|
      t.integer :scope_of_work_id
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :scope_items
  end
end

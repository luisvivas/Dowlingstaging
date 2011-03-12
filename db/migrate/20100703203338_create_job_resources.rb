class CreateJobResources < ActiveRecord::Migration
  def self.up
    create_table :job_resources do |t|
      t.integer :attachable_id
      t.string :attachable_type
      t.string :name
      t.string :category
      t.string :resource_file_name
      t.string :resource_content_type
      t.integer :resource_file_size
      t.datetime :resource_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :job_resources
  end
end

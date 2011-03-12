class CreateCorrespondences < ActiveRecord::Migration
  def self.up
    create_table :correspondences do |t|
      t.string :to_name
      t.string :to_email
      t.string :contact_id
      t.string :user_id
      t.boolean :outgoing
      t.string :from_name
      t.string :from_email
      t.string :subject
      t.text :body
      t.integer :attachments
      t.string :discussable_type
      t.integer :discussable_id
      t.timestamps
    end
  end

  def self.down
    drop_table :correspondences
  end
end

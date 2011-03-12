class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.string :first_name
      t.string :last_name
      t.string :department
      t.string :email
      t.string :telephone
      t.string :mobile
      t.string :fax
      t.integer :business_id

      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end

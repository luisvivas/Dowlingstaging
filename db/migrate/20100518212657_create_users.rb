class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :employee_number
      t.string :home_phone
      t.string :cell_phone
      t.integer :address_id
      
      t.rememberable
      t.trackable
      t.imap_authenticatable
      
      t.timestamps
    end
    add_index :users, :email, :unique => true
  
  end

  def self.down
    drop_table :users
  end
end

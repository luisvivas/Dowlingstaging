class AddInstallationToQuote < ActiveRecord::Migration
  def self.up
    add_column :quotes, :needs_installation, :boolean
  end

  def self.down
    remove_column :quotes, :needs_installation
  end
end

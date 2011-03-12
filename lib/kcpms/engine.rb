module KCPMS
  class Engine < Rails::Engine    
    # Get Compass to boot up. Looks for the compass.rb configuration file in config/
    initializer "KCPMS.configure_compass" do
      require 'compass'
      rails_root = (defined?(Rails) ? Rails.root : RAILS_ROOT).to_s
      file = File.join(rails_root, "config", "compass.rb") # See if the application has a config
      if ! File.exists?(file)
        file = File.expand_path('../../../config/compass.rb', __FILE__) # Use the boiler plate if not
      end
      Compass.add_project_configuration(file)
      Compass.configure_sass_plugin!
      Compass.handle_configuration_change!
    end
  end
end
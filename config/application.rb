require File.expand_path('../boot', __FILE__)

require 'rails/all'
# Auto-require default libraries and those for the current Rails environment.
Bundler.require :default, Rails.env

module Dowling
  
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those  specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    config.autoload_paths += %W(#{config.root}/lib/kcpms)
    
    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]
    # config.reload_plugins = true
    
    # Activate observers that should always be running
    # config.active_record.observers = :activity_observer # <- this guy is now in an initializer!

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
    # config.i18n.default_locale = :de
    
    # Configure generators values. Many other options are available, be sure to check the documentation.

    config.generators do |g|
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
    end
    
    config.cookie_verifier_secret = '0c7ab66f813f816a454da2b78892d05ee54db47a54232ac297a646d95bb07fee61a6f8e97a9b2415ddeda28fe02899d6d025961645425941e66bd057b5cd6ae2'
    config.session_store :cookie_store, :key => '_dpms_session'
    config.secret_token = '4f29b79ad18c257b5ccf2f31bce805086bf1126c655741e894d31b142e5bcb24367e1ab9d5502b4a431e83a6f0a9122aef3423d973279e6cecdd28a1782610c8'
    
    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters << :password
  end
end

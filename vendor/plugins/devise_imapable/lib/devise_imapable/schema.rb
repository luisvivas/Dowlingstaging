Devise::Schema.class_eval do

    # Creates email
    #
    # == Options
    # * :null - When true, allow columns to be null.
    # * :default - Should be set to "" when :null is false.
    def imap_authenticatable(options={})
      null = options[:null] || false
      default = options[:default] || ""

      apply_devise_schema :email, String, :null => null, :default => default
    end

end
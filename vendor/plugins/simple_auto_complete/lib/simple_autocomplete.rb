module SimpleAutocomplete
  VERSION = File.read( File.join(File.dirname(__FILE__),'..','VERSION') ).strip
end

# see Readme for details
class ActionController::Base
  def self.autocomplete_for(name, method, src_options = {}, &block)
    src_options = src_options.dup
    define_method("autocomplete_for_#{name}_#{method}") do
      options = src_options.dup
      methods = options.delete(:match) || [*method]
      condition = methods.map{|m| "LOWER(#{m}) LIKE ?"} * " OR "
      values = methods.map{|m| "%#{params[:q].to_s.downcase}%"}
      conditions = [condition, *values]
      scope_by = options.delete(:scope_by)
      scope = options.delete(:scope)
      scope.reload if scope.present?
      unless scope.present? 
        scope = options.delete(:class) || name
        scope = scope.to_s.camelize.constantize if scope.is_a?(Symbol)
      end
      
      find_options = {
        :order => "#{methods.first} ASC",
        :limit => 10
        }.merge!(options)

      @items = scope.scoped(find_options).where(conditions)
      @items = @items.where(scope_by => params[:scope]) if scope_by.present? && params[:scope].present?
      
      out = if block_given?
        instance_exec @items, &block
      else
        %Q[<%= @items.map {|item| h(item.#{methods.first})}.uniq.join("\n")%>]
      end
      render :inline => out
    end
  end
end

class ActiveRecord::Base
  # Store autocomplete field as association
  # in post.rb: autocomplete_for('user', 'name')
  # in user.rb add find_by_autocomplete :name
  # Post.first.auto_user_name=(value) will be resolved to a User, using User.find_by_autocomplete_name(value)
  def self.autocomplete_for(model, attribute, options={})
    model, name = autocomplete_model_and_name(model, options[:name])
    finder = autocomplete_finder_for(model, attribute)

    #auto_user_name= "Hans"
    define_method "auto_#{name}_#{attribute}=" do |value|
      send "#{name}=", model.send(finder, value)
    end

    #auto_user_name
    define_method "auto_#{name}_#{attribute}" do
      send(name).try(:send, attribute).to_s
    end
  end

  # Add association by autocomplete field
  # in post.rb add_by_autocomplete('user', 'name)  for has_many() association, like on github's collaborators search
  # in user.rb add find_by_autocomplete :name
  # Post.first.add_bu_auto_user_name=(value) will be resolved to a User, using User.find_by_autocomplete_name(value)
  def self.add_by_autocomplete(model, attribute, options={})
    model, name = autocomplete_model_and_name(model, options[:name])
    finder = autocomplete_finder_for(model, attribute)

    #add_user_by_autocomplete= "Hans"
    define_method "add_by_auto_#{name}_#{attribute}=" do |value|
      send(name.pluralize).send('<<', model.send(finder, value)) if value and !value.empty?
    end

    # avoid method missing error when rendering a form field
    define_method("add_by_auto_#{name}_#{attribute}"){}
  end

  def self.find_by_autocomplete(attribute)
    metaclass = (class << self; self; end)
    metaclass.send(:define_method, "find_by_autocomplete_#{attribute}") do |value|
      return if value.blank?
      self.first(:conditions => [ "LOWER(#{attribute}) = ?", value.to_s.downcase ])
    end
  end

  private

  def self.autocomplete_model_and_name(model, name)
    name = name || model.to_s.underscore
    name = name.to_s
    model = model.to_s.camelize.constantize
    [model, name]
  end

  # is the correct finder defined <-> warn users
  def self.autocomplete_finder_for(model, attribute)
    finder = "find_by_autocomplete_#{attribute}"
    unless model.respond_to? finder
      raise "#{model} does not respond to #{finder}, maybe you forgot to add auto_complete_for(:#{attribute}) to #{model}?"
    end
    finder
  end
end
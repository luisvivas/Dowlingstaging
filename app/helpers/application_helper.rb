module ApplicationHelper
  CLASSES_WITH_ACTIONS_TEMPLATES = [RequestForQuote, Quote, WorkOrder, Contact, Business, ProductCategory, Product, LengthProduct, SheetProduct]

  def assigned_resource(name = nil)
    name ||= controller.controller_name.singularize
    self.assigns[name]
  end

  def assigned_class(name = nil)
    ass = assigned_resource(name)
    if ass.present?
      return ass.class
    else
      begin
        ass ||= controller.controller_name.classify.constantize
      rescue StandardError
        return nil
      end
      return ass
    end
  end

  def page_title(t = nil)
    r = Settings.application_name + ": #{controller.controller_name.titleize}"
    if t.blank?
      r +=  " - #{controller.action_name.titleize}"
      assign = assigned_resource
      if assign.present? && assign.respond_to?(:best_identifier)
        r += " " + assign.best_identifier unless assign.respond_to?(:new_record?) && assign.new_record?
      end
    else
      r += t
    end
    r
  end

  def resource_actions
    if CLASSES_WITH_ACTIONS_TEMPLATES.include?(assigned_class)
      if [:new, :create, :index].include?(controller.action_name.to_sym)
        render 'collection_actions'
      elsif [:show, :edit, :update].include?(controller.action_name.to_sym)
        render 'actions'
      end
    elsif controller.controller_name == "reports"
      render 'actions'
    end
  end

  def actions_select(actions)
    if actions.length <= 3
      actions.inject("") do |acc, (msg, path)|
        acc += link_to msg, path
      end
    else
      select_tag("", ("<option>Quick Actions --- </option>" + options_for_select(actions)).html_safe, :class => "actions")
    end
  end

  def destroy_confirmation(record)
    "Are you sure you want to destroy #{record.best_identifier}? This cannot be undone!"
  end

  def display_new_user_profile_message
    flash[:success] = ("Welcome new user. Please take a minute to " + self.class.helpers.link_to("fill out your profile", edit_user_path(current_user)) + " in the system.").html_safe
  end

  def breadcrumb
    crumbs = []
    if controller.respond_to?(:index)
      crumbs.push(link_to(controller.controller_name.titleize, :controller => controller.controller_name, :action =>'index'))
    else
      crumbs.push(controller.controller_name.titleize)
    end
    crumbs.push(link_to(controller.action_name.titleize, :controller => controller.controller_name, :action =>controller.action_name))

    crumbs.join(' > ').html_safe
  end

  def permissioned_actions(default_record = nil, seperator = " | ", &block)
    rec = PermissionActionsDSL.new(default_record)
    block.call(rec) if block_given?
    permissioned_actions_from_array(rec.actions, seperator)
  end

  def permissioned_actions_from_array(actions, seperator = " | ")
    s = []
    actions.each do |(text, path, action, subject, options)|
      subject ||= path
      if (action == true || (action != false && Thwart.query(current_user, subject, action)))
        if path.nil?
          s.push text
        else
          s.push link_to(text, path, options)
        end
      end
    end
    s.join(seperator).html_safe
  end

  def permissioned_menu
    if user_signed_in?
      semantic_menu(:id => "menu") do |root|
        root.add "Dashboard", root_path, :class => "ss_sprite ss_application" if current_user.can_show?(:dashboard)
        root.add "Contacts", contacts_path, :class => "ss_sprite ss_group" do |contacts|
          contacts.add "Contact Manager", contacts_path, :class => "ss_sprite ss_group"
          contacts.add "New Contact", new_contact_path, :class => "ss_sprite ss_group_add" if current_user.can_create?(:contact)
          contacts.add "Business Manager", businesses_path, :class => "ss_sprite ss_briefcase" if current_user.can_show?(:business)
          contacts.add "New Business", new_business_path, :class => "ss_sprite ss_briefcase" if current_user.can_create?(:business)
        end  if current_user.can_show?(:contact)

        root.add "Work Orders", work_orders_path, :class => "ss_sprite ss_table" do |wos|
          wos.add "Work Queue", queue_work_orders_path, :class => "ss_sprite ss_table_go" if current_user.can_show?(:work_order_queue)
          wos.add "Work Order Manager", work_orders_path, :class => "ss_sprite ss_table"
          wos.add "New Work Order", new_work_order_path, :class => "ss_sprite ss_table_add" if current_user.can_create?(:work_order)
        end if current_user.can_show?(:work_order)

        root.add "Quotes", quotes_path, :class => "ss_sprite ss_page" do |qs|
          qs.add "Quote Manager", quotes_path, :class => "ss_sprite ss_page"
          qs.add "New Quote", new_quote_path, :class => "ss_sprite ss_page_add" if current_user.can_create?(:quote)
        end if current_user.can_show?(:quote)

        root.add "RFQs", request_for_quotes_path, :class => "ss_sprite ss_script" do |rfqs|
          rfqs.add "RFQ Queue", queue_request_for_quotes_path, :class => "ss_sprite ss_script_go" if current_user.can_create?(:rfq_queue)
          rfqs.add "RFQ Manager", request_for_quotes_path, :class => "ss_sprite ss_script"
          rfqs.add "New RFQ", new_request_for_quote_path, :class => "ss_sprite ss_script_add" if current_user.can_create?(:request_for_quote)
        end if current_user.can_show?(:request_for_quote)

        root.add "Products", products_path, :class => "ss_sprite ss_shape_square" do |products|
          products.add "Product Manager", products_path, :class => "ss_sprite ss_shape_square"
          products.add "New Product", new_product_path, :class => "ss_sprite ss_shape_square_add" if current_user.can_create?(:product)
          products.add "Category Manager", product_categories_path, :class => "ss_sprite ss_shape_move_front" if current_user.can_show?(:product_category)
          products.add "New Category", new_product_category_path, :class => "ss_sprite ss_shape_move_front" if current_user.can_create?(:product_category)
        end if current_user.can_show?(:product)

        root.add "Users", users_path, :class => "ss_sprite ss_user" do |users|
          users.add "User Manager", users_path, :class => "ss_sprite ss_user"
          users.add "New User", new_user_path, :class => "ss_sprite ss_user_add" if current_user.can_create?(:user)
        end if current_user.can_show?(:user)

        root.add "Reports", reports_path, :class => "ss_sprite ss_coins" if current_user.can_show?(:report)
        root.add "Settings", settings_path, :class => "ss_sprite ss_cog" if current_user.can_update?(:settings)
        root.add "End of Day Sign Out", new_end_of_day_report_path
      end
    else
      semantic_menu(:id => "menu") do |root|
        root.add "Sign In", new_user_session_path
      end
    end
  end

  # Handy select option generators which append values to the options as HTML5 data attributes
  def options_for_select_with_data(container, selected = nil)
    return container if String === container

    container = container.to_a if Hash === container
    selected, disabled = extract_selected_and_disabled(selected)

    options_for_select = container.inject([]) do |options, element|
      text, data, value = option_text_value_data(element)
      selected_attribute = ' selected="selected"' if option_value_selected?(value, selected)
      disabled_attribute = ' disabled="disabled"' if disabled && option_value_selected?(value, disabled)
      data_attribute = data.map{ |k,v| %( data-#{k.to_s.gsub('_', '-')}="#{v}"%) }.join
      options << %(<option value="#{html_escape(value.to_s)}"#{selected_attribute}#{disabled_attribute}#{data_attribute}>#{html_escape(text.to_s)}</option>)
    end

    options_for_select.join("\n").html_safe
  end

  # Handy select option generators which append values to the options as HTML5 data attributes
  def options_from_collection_for_select_with_data(collection, value_method, text_method, data_methods, selected = nil)
    data_methods = Array.wrap(data_methods)
    options = collection.map do |element|
      datas = data_methods.inject({}) {|datas, m| datas[m] = element.send(m); datas}
      [element.send(text_method), datas, element.send(value_method)]
    end
    selected, disabled = extract_selected_and_disabled(selected)
    select_deselect = {}
    select_deselect[:selected] = extract_values_from_collection(collection, value_method, selected)
    select_deselect[:disabled] = extract_values_from_collection(collection, value_method, disabled)

    options_for_select_with_data(options, select_deselect)
  end

  def link_to_discussable(correspondence)
    d = correspondence.discussable
    if d.present?
      link_to d.best_identifier, d
    else
      "#{c.discussable_type.humanize} ##{c.discussable_id} (destroyed)"
    end
  end

  def grade_and_finish(grade = nil, finish = nil)
    grade = truncate(grade) if grade.present?
    finish = truncate(finish) if finish.present?
    str = ""
    if grade.present?
      if finish.present?
        str = "Grade: " + grade + "<br/>" + "Finish: " + finish
      else
        str = "Grade: " + grade
      end
    else
      if finish.present?
        str = "Finish: " + finish
      end
    end
    str.html_safe
  end

  def overdue_item_class(overdueable)
    "overdue" if overdueable.overdue?
  end

  def current_user_calendar
    GCal4Ruby::Calendar.to_iframe(current_user.email, :width => "500", :height => "200", :viewMode => "AGENDA").html_safe
  end

  def best_calendar
    if current_user.can_show?(:system_calendar)
      id = Settings.calendar_id
    else
      id = current_user.email
    end
    GCal4Ruby::Calendar.to_iframe(id, :width => "1120", :mode => "week").html_safe
  end

  def letterhead_email(user = nil)
    if user
      user.email
    else
      "office@dowlingmetal.com"
    end
  end
  
  private

  def option_text_value_data(option)
    # Options are [text, value] pairs or strings used for both.
    if !option.is_a?(String) and option.respond_to?(:first) and option.respond_to?(:last)
      if option.respond_to?(:second) && option.second != option.last
        [option.first, option.second, option.last]
      else
        [option.first, {}, option.last]
      end
    else
      [option, {}, option]
    end
  end

  def format_duration(seconds)
    h = (seconds/3600).floor
    m = ((seconds - 3600*h)/60).floor

    # return formatted time
    return "%d hours, %02d minutes" % [ h, m ]
  end

  def profit_class(num)
    num > 0 ? "gain" : "loss"
  end
end

module ActionView
  module Helpers
    class FormBuilder
      include ActionView::Helpers::TextHelper
      def formatted_error_messages(options = {})
        error_messages({:class => "error",
                        :message => nil,
                        :header_tag => "h3",
                        :header_message => "This #{@object_name.to_s.humanize} couldn't be saved because of " + pluralize(@object.errors.length, 'error') + ":"}.merge!(options))
      end
    end
  end
end

class PermissionActionsDSL
  include ApplicationHelper
  include ActionView::Helpers::UrlHelper
  include Rails.application.routes.url_helpers
  attr_accessor :actions

  def initialize(default_record = nil)
    @record = default_record
    @actions = []
  end
  def controller
    nil
  end
  def link(*args)
    @actions.push args
  end
  def text(text, action, subject)
    @actions.push([text, nil, action, subject])
  end
  def show_link(text = "Show")
    self.link(text, @record, :show)
  end
  def correspondence_link(text = "Corresp.")
    self.link(text, polymorphic_path([@record, Correspondence]), :show, :correspondence)
  end
  def resources_link(text = "Resources")
    self.link(text, polymorphic_path([@record, JobResource]), :show, :job_resource)
  end
  def edit_link(text = "Edit")
    self.link(text, edit_polymorphic_path(@record), :update)
  end
  def destroy_link(text = "Destroy")
    self.link(text, @record, :destroy, @record, {:confirm => destroy_confirmation(@record), :method => :delete})
  end
  def trifecta
    self.show_link
    self.edit_link
    self.destroy_link
  end
end
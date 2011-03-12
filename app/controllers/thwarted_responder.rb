class ThwartedResponder < ActionController::Responder
  ActionMap = {:new => :create, :view => :show, :edit => :update}
  def respond
    rz = @options[:thwart_resource]
    rz ||= @resource
    action = @options[:thwart_action]
    if controller.action_name == "index"
      action ||= :show 
      rz ||= @resource.first.thwart_name if @resource.respond_to?(:first) && @resource.first.respond_to?(:thwart_name)
    end
    action ||= controller.action_name.to_sym
    action = ActionMap[action] if ActionMap.has_key?(action)
    controller.thwart_access(rz, action) unless controller.devise_controller?
    super
  end
end
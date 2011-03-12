require 'carmen/action_view_helpers'

module ActionView
  module Helpers
    module FormOptionsHelper
      def state_options_for_select(selected = nil, country = Carmen.default_country)
        begin
          options_for_select(Carmen.states(country), selected)
        rescue Carmen::StatesNotSupported
          ""
        end
      end
    end
  end
end
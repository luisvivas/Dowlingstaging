require "kcpms"
Carmen.default_country = 'CA'
ActiveRecord::Base.observers = :activity_observer, :correspondence_email_observer, :line_item_observer, :request_for_quote_queue_observer
ActiveRecord::Base.instantiate_observers

Date::DATE_FORMATS[:default] = "%d/%m/%Y"
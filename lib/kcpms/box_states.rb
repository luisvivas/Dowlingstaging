module BoxStates
  class State
    class << self
      attr_accessor :class_name
      attr_accessor :order
    end
    def self.to_class
      return self.class_name if self.class_name.present?
      self.to_s.split('::').last.underscore
    end
    def self.<=>(state)
      @order <=> state.order
    end
    def self.<(state)
      self.<=>(state) == -1
    end
    def self.>(state)
      self.<=>(state) == 1
    end
    def self.>=(state)
      self.<=>(state) === 0..1
    end
    def self.<=(state)
      self.<=>(state) === (-1..0)
    end
    def self.==(state)
      self.<=>(state) == 0
    end
    def self.sort_order(number)
      self.order = number
    end
    def self.complete?
      false
    end
  end
  
  class Incomplete  < State 
    sort_order 1
  end
  class InProgress  < State 
    sort_order 2
  end
  class Complete    < State 
    sort_order 3
    def self.complete?
      true
    end
  end

end
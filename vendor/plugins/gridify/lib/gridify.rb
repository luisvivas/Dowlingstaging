require 'gridify/grid'
module Gridify
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    attr_accessor :grids
    
    def gridify(*args, &block)
      return false unless self.table_exists?
      grid = Gridify::Grid.new( self, *args, &block)
            
      @grids ||= {}
      @grids[grid.name.to_sym] = grid 
      
      unless self.respond_to?(:gridified)
        class_eval <<-EOV
            scope :gridified, lambda {|name, params|
              grid = grids[name]
              grid.update_from_params( params )
              grid.current_scope
            }    
        EOV
      end
    end
    
    def grids
      @grids || {}
    end
    
    def grid
      grids[:grid]  
    end
    
  end
end
 
class ActiveRecord::Base
  include Gridify
end
module KCPMS
  module Markupable
    def markup_multiplier
      self.markup / 100 + 1
    end
  end
end
class Array
  def pretty_s
    case self.length
      when 0 then "none"
      when 1 then self.first
      when 2 then self.join(' and ')
      else self[0..1].join(', ') + " and #{self.length - 2} more"
    end
  end
end
class Object
def returning(value)
  yield(value)
  value
end
end
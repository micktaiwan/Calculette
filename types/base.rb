class MObject < Object

  def to_s
    "<\"#{@name}\": #{self.class.name}/#{@param_names.size}>"
  end

end

class Context < MObject

  attr_accessor :symbols#, :parser, :transf

  def initialize
    @symbols    = ST.new
  end

end


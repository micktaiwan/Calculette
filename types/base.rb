class MRuntimeError < Exception
end

class MObject < Object

  def to_s
    "<\"#{@name}\": #{self.class.name}/#{@param_names.size}>"
  end

end

# a context with a symbol table to use for locals variables
class Context < MObject

  #attr_accessor :symbols#, :parser, :transf
  attr_reader :name

  def initialize(name="not named")
    @name = name
    @symbols    = Hash.new
  end

  def [](name)
    @symbols[name.to_s]
  end

  def []=(name, value)
    @symbols[name.to_s] = value
  end

  def clear
    @symbols.clear
  end

  def print_all
    puts "#{@symbols.size} symbols"
    @symbols.each { |name, value|
      puts "- #{name}: #{value.to_s}"
      }
  end

  def clear
    @symbols.clear
  end

end


require 'brain'

# symbols table
class ST

  attr_accessor :symbols

  def initialize
    @symbols = Hash.new
  end

  def [](name)
    @symbols[name.to_s]
  end

  def []=(name, value)
    @symbols[name.to_s] = value
  end

  def print_all
    puts "#{@symbols.size} symbols"
    @symbols.each { |name, value|
      puts "- #{name}:\t\"#{value}\" (#{value.class.name})"
      }
  end

end

class MObject

  def to_s
    self.class.name
  end

end

class Function < Brain

  def initialize(n,a,b)
    super({:no_lib_loading=>true}) # TODO: we need contexts !
    @name, @param_names, @body = n,a.map{|a| a.to_s},b
  end

  def call(vars)
    # initialize local variables
    vars.each_with_index { |a,i|
      @symbols[@param_names[i]] = a
      }
    # execute the function body
    execute(@body)
  end

  def to_s
  end

end


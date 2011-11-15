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
      puts "- #{name}: #{value.to_s}"
      }
  end

end


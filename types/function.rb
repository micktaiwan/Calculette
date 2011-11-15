class Function < MObject

  def initialize(n,a,b, parser)
    super()
    @context = Context.new
    @name, @param_names, @body = n,a.map{|a| a.to_s},b
    @parser = parser
  end

  def call(vars)
    # initialize local variables
    vars.each_with_index { |a,i|
      @context.symbols[@param_names[i]] = a
      }
    # execute the function body
    @parser.execute(@body, @context)
  end

  def to_s
    "<\"#{@name}\": #{self.class.name}/#{@param_names.size}>"
  end

end


class Function < MObject

  def initialize(n,a,b, parser)
    super()
    @context = Context.new("function")
    @name, @param_names, @body = n,a.map{|a| a.to_s},b
    @parser = parser
  end

  def call(vars)
    raise MRuntimeError, "wrong number of argument for #{self.to_s} (#{vars.size} for #{@param_names.size} )" if vars.size != @param_names.size
    # initialize local variables
    @context.clear
    vars.each_with_index { |a,i|
      @context[@param_names[i]] = a
      }
    # execute and return the function body
    @parser.execute(@body, @context)
  end

  def to_s
    "<\"#{@name}\": #{self.class.name}/#{@param_names.size}>"
  end

end


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


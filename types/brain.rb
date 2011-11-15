require File.join(File.dirname(__FILE__), 'grammar')
require 'parslet/convenience'

class Brain < MObject # TODO: rename Brain as Context ?

  attr_reader :parser, :last_error_tree, :symbols

  def initialize(options={})
    super()
    @symbols    = ST.new
    @parser     = MathGrammarParser.new
    @transf     = MathGrammarTransform.new
    @last_error_tree = "None"
    load_file("lib") unless options[:no_lib_loading]
    #parser = MathGrammarParser.new.identifier.parse_with_debug("a")
    #p parser
  end

  def load_file(file, options={})
    begin
      execute(File.open(file, "rb").read, options)
    rescue Exception=>e
      puts e
    end
  end

  def assign(var_name, value)
    @symbols[var_name] = value
  end

  def value_of(var_name)
    @symbols[var_name]
  end

  # options:
  #   :repeat_input => print input again before execution
  def execute(input, options={})
    puts input if options[:repeat_input]
    begin
      tree = @parser.parse_with_debug(input)
      #p tree
    rescue  Parslet::ParseFailed => e
      puts e.message.gsub(/[\n]/,'\n')
      @last_error_tree = @parser.error_tree
      return
    end
    return @transf.apply(tree, :brain => self)
  end

  def self.print_ast(ast, options={})
    if ast.class.name=='Hash'
      print "Could not simplify "
      p ast
    elsif ast.class.name=='Array' # list of commands
      ast.each { |ast|
        print_ast(ast, options)
        }
    else
      puts ast if !options[:hide_results]
    end
  end

  def assign(id,value)
    @symbols[id.to_s] =  value
    "#{id} = #{value}"
  end

  def value_of(id)
    @symbols[id.to_s]
  end

  def op(op,left,right)
    if !left
      return "left operator is not defined"
    end
    if !right
      return "right operator is not defined"
    end
    begin
      case op
      when  '+'
        left+right
      when  '-'
        left-right
      when  '*'
        left*right
      when  '/'
        left.to_f/right
      end
    rescue Exception=>e
      e # if the operation is not possible just return the result in plain english
    end
  end

  def fdef(name,args,body)
    @symbols[name.to_s] = Function.new(name,args,body.to_s.strip)
    "new function '#{name}(#{args.join(',')})'"
  end

  def fcall(name,vars)
    f = @symbols[name.to_s]
    raise "unknown function '#{name}(#{vars.join(',')})" if f.class.name!='Function'
    return f.call(vars)
  end

end


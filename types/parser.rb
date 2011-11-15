require File.join(File.dirname(__FILE__), 'grammar')
require 'parslet/convenience'

class Parser < MObject # TODO: rename Brain as Context ?

  attr_reader :global_context, :last_error_tree, :parser, :transf

  def initialize(options={})
    super()
    @last_error_tree = "None"
    @global_context    = Context.new
    @parser     = MathGrammarParser.new
    @transf     = MathGrammarTransform.new

    load_file("lib") unless options[:no_lib_loading]
    #parser = MathGrammarParser.new.identifier.parse_with_debug("a")
    #p parser
  end

  def load_file(file, context=@global_context, options={})
    begin
      execute(File.open(file, "rb").read, context, options)
    rescue Exception=>e
      puts e
      puts e.backtrace
    end
  end

  def assign(var_name, value)
    @current_context.symbols[var_name] = value
  end

  def value_of(var_name)
    @current_context.symbols[var_name]
  end

  # options:
  #   :repeat_input => print input again before execution
  def execute(input, context=@global_context, options={})
    @current_context = context
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
    @current_context.symbols[id.to_s] =  value
    "#{id} = #{value}"
  end

  def value_of(id)
    @current_context.symbols[id.to_s]
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
    @current_context.symbols[name.to_s] = Function.new(name,args,body.to_s.strip, self)
    "new function '#{name}(#{args.join(',')})'"
  end

  def fcall(name,vars)
    f = @current_context.symbols[name.to_s]
    raise "unknown function '#{name}(#{vars.join(',')})" if f.class.name!='Function'
    return f.call(vars)
  end

end


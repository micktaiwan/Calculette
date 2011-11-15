require File.join(File.dirname(__FILE__), 'grammar')
require 'parslet/convenience'

class Parser < MObject

  attr_reader :global_context, :last_error_tree, :parser, :transf

  def initialize(options={})
    super()
    @last_error_tree  = "None"
    @global_context   = Context.new("global")
    @parser           = MathGrammarParser.new
    @transf           = MathGrammarTransform.new
    load_file("lib") unless options[:no_lib_loading]
    load_file("basics")
    t = @parser.parse("(a=2)+3")
    p t
  end

  def load_file(file, context=@global_context, options={})
    begin
      execute(File.open(file, "rb").read, context, options)
    rescue Exception=>e
      puts e
      puts e.backtrace
    end
  end

  def assign(var_name, value, context)
    #"assignation of #{var_name} = #{value} (context: #{context.name})"
    context[var_name.to_s] = value
  end

  def value_of(var_name, context)
    v = context[var_name.to_s]
    puts "#{var_name} = #{v ? v : "nil"} (context: #{context.name})"
    raise MRuntimeError, "Error: #{var_name} is not defined (context: #{context.name})" if !v
    v
  end

  # options:
  #   :repeat_input => print input again before execution
  def execute(input, context=@global_context, options={})
    puts input if options[:repeat_input]
    begin
      tree = @parser.parse_with_debug(input)
      #p tree
      ast = @transf.apply(tree, :brain => self, :context=>context)
      #p ast
      return ast
    rescue  Parslet::ParseFailed => e
      puts e.message.gsub(/[\n]/,'\n')
      @last_error_tree = @parser.error_tree
      return nil
    rescue  MRuntimeError => e
      puts e.message
      return nil
    end
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

  def fdef(name,args,body, context)
    context[name.to_s] = Function.new(name,args,body.to_s.strip, self)
    "new function '#{name}(#{args.join(',')})' in context '#{context.name}'"
  end

  def fcall(name,vars, context)
    f = context[name.to_s]
    raise "unknown function '#{name}(#{vars.join(',')}) in context '#{context.name}'" if f.class.name!='Function'
    return f.call(vars)
  end

end


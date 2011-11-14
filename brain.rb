require 'grammar'

class FunCall < Struct.new(:name, :args);
  def eval
    p args.map { |s| s.eval }
  end
end

class Brain

  attr_reader :parser

  def initialize
    super
    @symbols  = Hash.new
    @parser   = MathGrammarParser.new
    @transf   = MathGrammarTransform.new
    load_file("defaults", false)
  end

  def load_file(file, display_results=true)
    begin
      File.open(file, "rb").read.split("\n"). each do |line|
        line = line.strip
        if line.empty? and display_results
          puts
        else
          execute(line, true, display_results)
        end
      end
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

  def execute(input, repeat_input=false, display_results=true)
    print input + "\t => " if repeat_input and display_results
    tree = @parser.parse(input)
    #p tree
    ast = @transf.apply(tree, :brain => self)
    if ast.class.name=='Array' or ast.class.name=='Hash'
      print "Could not simplify "
      p ast
    else
      puts ast if display_results
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

end


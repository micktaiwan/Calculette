require 'rubygems'
require 'parslet'

class MathGrammarParser < Parslet::Parser
  # Single character rules
  rule(:lparen)     { str('(') >> space? }
  rule(:rparen)     { str(')') >> space? }
  rule(:comma)      { str(',') >> space? }
  rule(:assign_sign){ str('=') >> space? }
  rule(:spaces)     { space.repeat }
  rule(:space)      { multiline_comment | line_comment | match["\s"] }
  rule(:space?)     { spaces.maybe }
  rule(:line_comment) { str('#') >> (newline.absent? >> any).repeat }
  rule(:multiline_comment) { str('/*') >> (str('*/').absent? >> any).repeat >> str('*/') }
  rule(:newline) { str("\n") >> str("\r").maybe }

  # Things
  rule(:integer)    { match('[0-9]').repeat(1).as(:integer) >> space? }
  rule(:identifier) { match['a-z'].repeat(1).as(:identifier) >> space? }
  rule(:sum_op)     { match('[+-]') >> space? }
  rule(:mul_op)     { match('[*/]') >> space? }

  # Grammar parts
  rule(:sum) do
    mul.as(:left) >>  sum_op.as(:op) >>  sum.as(:right) |
    mul
  end
  rule(:mul) do
    atom.as(:left) >> mul_op.as(:op) >> mul.as(:right) |
    atom
  end
  rule(:atom)       { integer | identifier}
  rule(:arglist)    { expression >> (comma >> expression).repeat }
  rule(:funcall)    { identifier.as(:funcall) >> lparen >> arglist.as(:arglist) >> rparen }
  rule(:assign)     { identifier >> assign_sign >> expression.as(:value) }

  # stuff that can be a right value
  rule(:expression) { sum | identifier }

  rule(:command) do
    assign.as(:assign)  |
    sum                 |
    funcall             |
    integer
  end

  rule(:line)   { space? >> command.maybe }
  rule(:lines)  { line >> (newline >> lines.maybe).maybe }
  root :lines

end

class MathGrammarTransform < Parslet::Transform
  rule(:integer => simple(:i)) { i.to_i}
  rule(:left => simple(:left), :right => simple(:right), :op => simple(:op))  { brain.op(op, left,right) }
  rule(:left => subtree(:tree)) { tree }
  rule(:right => subtree(:tree)) { tree }
  #rule(:mul => simple(:int))  { int }
  #rule(:right=> simple(:int)) { int }
  rule(:assign=>{:value=>simple(:value), :identifier=>simple(:id)}) do
    brain.assign(id,value)
  end
  rule(:identifier=>simple(:id)) do
    v = brain.value_of(id)
    if !v;"#{id} is not defined";else;v;end
  end
  rule(:funcall => 'puts', :arglist => subtree(:arglist))             { FunCall.new('puts', arglist) }
end


require 'rubygems'
require 'parslet'
require File.join(File.dirname(__FILE__), 'transforms')

class MathGrammarParser < Parslet::Parser

  # Simple things
  rule(:lparen)             { str('(') >> space? }
  rule(:rparen)             { str(')') >> space? }
  rule(:comma)              { str(',') >> space? }
  rule(:assign_sign)        { str('=') >> space? }
  rule(:newline)            { match['\\n'] }
  rule(:space)              { match["\s"] | match["\t"]}
  rule(:spaces)             { space.repeat}
  rule(:space?)             { spaces.maybe }
  rule(:empty_line)         { space? >> newline }
  rule(:lines_comment)      { str('/*') >> (str('*/').absent? >> any).repeat >> str('*/') >> space? }
  rule(:end_comment)        { str('#') >> (newline.absent? >> any).repeat }
  rule(:comment)            { lines_comment | end_comment }
  rule(:identifier)         { match['a-z'].repeat(1).as(:identifier) >> space? }
  rule(:separator)          { str(';') }

  # Arithmetic
  rule(:expression)         { sum | variable } # expression: stuff that can be a right value
  rule(:integer)            { match('[0-9]').repeat(1).as(:integer) >> space? }
  rule(:variable)           { identifier.as(:variable) } # gets simplified into a value, an "identifier" does not
  rule(:sum_op)             { match('[+-]') >> space? }
  rule(:mul_op)             { match('[*/]') >> space? }
  rule(:atom)               { integer | fcall.as(:fcall) | variable}
  rule(:assign)             { identifier >> assign_sign >> expression.as(:value) }
  rule(:sum) do
    mul.as(:left) >>  sum_op.as(:op) >>  sum.as(:right) |
    mul
  end
  rule(:mul) do
    atom.as(:left) >> mul_op.as(:op) >> mul.as(:right) |
    atom
  end

  # lists
  rule(:varlist)    { expression >> (comma >> expression).repeat }
  rule(:arglist)    { argument >> (comma >> argument).repeat }
  rule(:pvarlist)   { (lparen >> varlist.repeat >> rparen).as(:plist) }
  rule(:parglist)   { (lparen >> arglist.repeat >> rparen).as(:plist) }

  # functions
  rule(:fdef_keyword) { str("def ") >> space? }
  rule(:fend_keyword) { str("endf") >> space? }
  rule(:argument)     { identifier.as(:argument) }
  rule(:fdef)         { fdef_keyword >> identifier.as(:name) >> parglist.as(:arglist) >> (newline|separator) >> fbody.as(:body) >> fend_keyword}
  rule(:fbody)        { (fend_keyword.absnt? >> any).repeat(1) }
  rule(:fcall)        { identifier.as(:name) >> pvarlist.as(:varlist) }

  # root
  rule(:command) do
    fdef.as(:fdef)        |
    assign.as(:assign)    |
    sum
  end
  rule(:com_and_comment)  { command >> end_comment.maybe }
  rule(:commands)         { com_and_comment >> separator.maybe >> commands.repeat }
  rule(:line)             { commands | comment | spaces }
  rule(:lines)            { line >> (newline >> lines).repeat }
  root :lines

end


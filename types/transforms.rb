class MathGrammarTransform < Parslet::Transform
  rule(:integer   => simple(:i))     { i.to_i}
  rule(:argument  => simple(:txt))   { txt.to_sym}
  rule(:left      => subtree(:tree)) { tree }
  rule(:right     => subtree(:tree)) { tree }
  rule(:line      => subtree(:tree)) { tree }
  rule(:left      => simple(:left),
       :right     => simple(:right),
       :op        => simple(:op))    { brain.op(op, left,right) }
  rule(:identifier  => simple(:id)) { id.to_s }
  rule(:variable  => simple(:id)) do
    v = brain.value_of(id, context)
    if !v;"#{id} is not defined";else;v;end
  end

  # assignment
  rule(:assign    => {:value=>simple(:value), :identifier=>simple(:id)}) do
    brain.assign(id,value, context)
  end

  # Hacks so that "()" returns as []...
  rule(:plist=>sequence(:arr)) { arr }
  rule(:plist=>"()") { [] }

  # helpers
  rule(:puts=>simple(:arg)) { puts arg.to_s }

  # functions
  rule(:fdef=>{
          :name=>simple(:name),
          :arglist=>sequence(:args),
          :body=>simple(:body)
        }) do
    brain.fdef(name,args,body, context)
  end
  rule(:fcall=>{:name=>simple(:name), :varlist=>sequence(:vars)}) do
    brain.fcall(name, vars, context)
  end
end


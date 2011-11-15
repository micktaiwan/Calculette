class MathGrammarTransform < Parslet::Transform
  rule(:integer   => simple(:i))     { i.to_i}
  rule(:argument  => simple(:txt))   { txt.to_sym}
  rule(:left      => subtree(:tree)) { tree }
  rule(:right     => subtree(:tree)) { tree }
  rule(:line      => subtree(:tree)) { tree }
  rule(:left      => simple(:left),
       :right     => simple(:right),
       :op        => simple(:op))    { brain.op(op, left,right) }
  rule(:variable  => simple(:id)) do
    v = brain.value_of(id)
    if !v;"#{id} is not defined";else;v;end
  end

  # assignment
  rule(:assign    => {:value=>simple(:value), :identifier=>simple(:id)}) do
    brain.assign(id,value)
  end

  # Hacks so that "()" returns as []...
  rule(:plist=>sequence(:arr)) { arr }
  rule(:plist=>"()") { [] }

  # functions
  rule(:fdef=>{
          :name=>simple(:name),
          :arglist=>sequence(:args),
          :body=>simple(:body)
        }) do
    brain.fdef(name,args,body)
  end
  rule(:fcall=>{:name=>simple(:name), :varlist=>sequence(:vars)}) do
    brain.fcall(name,vars)
  end
end


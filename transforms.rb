class MathGrammarTransform < Parslet::Transform
  rule(:integer   => simple(:i))     { i.to_i}
  rule(:argument  => simple(:txt))   { txt.to_sym}
  rule(:left      => simple(:left),
       :right     => simple(:right),
       :op        => simple(:op))    { brain.op(op, left,right) }
  rule(:left      => subtree(:tree)) { tree }
  rule(:right     => subtree(:tree)) { tree }
  rule(:line      => subtree(:tree)) { tree }
  rule(:assign    => {:value=>simple(:value), :identifier=>simple(:id)}) do
    brain.assign(id,value)
  end
  rule(:variable  => simple(:id)) do
    v = brain.value_of(id)
    if !v;"#{id} is not defined";else;v;end
  end
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

  #rule(:funid => simple(:name)) { name.to_s }
  #rule(:name => :name, :arglist => subtree(:arglist))             { @brain.funcall(name, arglist) }
end


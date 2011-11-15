require File.dirname(__FILE__) + '/../types'

describe "spaces" do
  before(:all) do
    @context   = Context.new("global")
    @parser    = MathGrammarParser.new
    @transf    = MathGrammarTransform.new
  end

  it "spaces" do
    @parser.space.parse(" ").to_s.should eq(" ")
    @parser.space.parse("\n").should raise_error(Parslet::ParseFailed)
  end

end


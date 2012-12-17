require 'treetop'
Treetop.load 'parser'

describe "Expressions" do
  def parse(input)
    ArithmeticParser.new.parse(input).to_sexp
  end

  def build(string)
    Expr.build parse(string)
  end

  def evaluate(string, env = {})
    build(string).evaluate(env)
  end

  def simplify(string)
    build(string).simplify
  end

  def derive(string)
    build(string).derive(:x)
  end

  describe "assignment" do
    it "supports evaluation" do
      evaluate('x + y', x: 1, y: 2).should eq 3
      evaluate('sin(0)').should eq 0
      evaluate("cos(#{Math::PI / 2})").should be_within(0.0001).of(0)
      evaluate('-2').should eq(-2)
    end

    it "supports comparison" do
      build('1 + 2 * 3').should eq build('1 + 2 * 3')
      build('x + 2').should_not eq build('2 + x')
    end

    it "supports simplification" do
      simplify('x + 0').should eq build('x')
      simplify('0 + x').should eq build('x')
      simplify('0 * x').should eq build('0')

      simplify('x * 0').should eq build('0')
      simplify('x * 1').should eq build('x')
      simplify('1 * x').should eq build('x')
      simplify('1 * x').should eq build('x')

      simplify('2 * (x * 0)').should eq build('0')

      simplify('0 + 1 * (3 * 0)').should eq build('0')
    end

    it "can derive expressions" do
      derive('x').should eq build('1')
      derive('y').should eq build('0')

      derive('x + x').should eq build('2')
      derive('x * x').should eq build('x + x')
      derive('x * x * x').should eq build('x * x + x * (x + x)')
    end
  end

  describe "pasrser" do
    it "parses numbers" do
      parse('4').should eq [:number, 4]
      parse('12345').should eq [:number, 12345]
      parse('3.14').should eq [:number, 3.14]
      parse('27.31').should eq [:number, 27.31]
    end

    it "parses addition" do
      parse('2+4').should eq [:+, [:number, 2], [:number, 4]]
      parse('2 + 4').should eq [:+, [:number, 2], [:number, 4]]
      parse('2+ 4').should eq [:+, [:number, 2], [:number, 4]]
      parse('2 +4').should eq [:+, [:number, 2], [:number, 4]]
      parse('3.14 + 2').should eq [:+, [:number, 3.14], [:number, 2]]
    end

    it "parses multiplication" do
      parse('4*2').should eq [:*, [:number, 4], [:number, 2]]
      parse('4 *2').should eq [:*, [:number, 4], [:number, 2]]
      parse('4* 2').should eq [:*, [:number, 4], [:number, 2]]
      parse('4 * 2').should eq [:*, [:number, 4], [:number, 2]]
      parse('3.14 * 2.71').should eq [:*, [:number, 3.14], [:number, 2.71]]
    end


    it "parses with arithmetic operator priority" do
      parse('1 + 2 * 3').should eq [:+, [:number, 1], [:*, [:number, 2], [:number, 3]]]
      parse('1 * 2 + 3').should eq [:+, [:*, [:number, 1], [:number, 2]], [:number, 3]]
    end

    it "parses parenthesis" do
      parse('(1 + 2) * 3').should eq [:*, [:+, [:number, 1], [:number, 2]], [:number, 3]]
      parse('1 * (2 + 3)').should eq [:*, [:number, 1], [:+, [:number, 2], [:number, 3]]]
    end

    it "parses exponentiation" do
      parse('2^3').should eq [:^, [:number, 2], [:number, 3]]
      parse('1 + 2^3 * 4').should eq [:+, [:number, 1],
                                          [:*, [:^, [:number, 2], [:number, 3]],
                                               [:number, 4]]]
    end

    it "parses negation" do
      parse('-2').should eq [:-, [:number, 2]]
      parse('-1 + -2 + -3').should eq [:+, [:-, [:number, 1]],
                                           [:+, [:-, [:number, 2]],
                                                [:-, [:number, 3]]]]
    end

    it "parses variables" do
      parse('x').should eq [:variable, :x]
      parse('x + 1').should eq [:+, [:variable, :x], [:number, 1]]
      parse('x^2').should eq [:^, [:variable, :x], [:number, 2]]
    end

    it "parses functions" do
      parse('sin(x)').should eq [:sin, [:variable, :x]]
      parse('cos(x)').should eq [:cos, [:variable, :x]]
    end
  end
end

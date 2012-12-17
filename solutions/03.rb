class Expr
  def self.build(ast)
    head, *tail = ast
    case head
      when :+ then Addition.new(*all(tail))
      when :* then Multiplication.new(*all(tail))
      when :- then Negation.new(*all(tail))
      when :sin then Sine.new(*all(tail))
      when :cos then Cosine.new(*all(tail))
      when :number then Number.new(*tail)
      when :variable then Variable.new(*tail)
    end
  end

  def self.all(expressions)
    expressions.map { |expression| build expression }
  end

  def +(other)
    Addition.new self, other
  end

  def *(other)
    Multiplication.new self, other
  end

  def -@
    Negation.new self
  end

  def simplify
    self
  end

  def derive(var)
    derivative(var).simplify
  end
end

class Unary < Expr
  attr_reader :expr

  def initialize(expr)
    @expr = expr
  end

  def ==(other)
    self.class == other.class and self.expr == other.expr
  end

  def exact?
    expr.exact?
  end
end

class Binary < Expr
  attr_reader :left, :right

  def initialize(left, right)
    @left  = left
    @right = right
  end

  def ==(other)
    self.class == other.class and
      self.left == other.left and
      self.right == other.right
  end

  def simplify
    self.class.new left.simplify, right.simplify
  end

  def exact?
    left.simplify.exact? and right.simplify.exact?
  end
end

class Number < Unary
  def evaluate(env = {})
    expr
  end

  def self.zero
    Number.new(0)
  end

  def self.one
    Number.new(1)
  end

  def derivative(varible)
    Number.zero
  end

  def exact?
    true
  end

  def to_s
    expr.to_s
  end
end

class Addition < Binary
  def evaluate(env = {})
    left.evaluate(env) + right.evaluate(env)
  end

  def simplify
    if exact? then Number.new(left.simplify.evaluate + right.simplify.evaluate)
    elsif left == Number.zero then right.simplify
    elsif right == Number.zero then left.simplify
    else super
    end
  end

  def derivative(var)
    left.derivative(var) + right.derivative(var)
  end

  def to_s
    "(#{left} + #{right})"
  end
end

class Multiplication < Binary
  def evaluate(env = {})
    left.evaluate(env) * right.evaluate(env)
  end

  def simplify
    if exact? then Number.new(left.simplify.evaluate * right.simplify.evaluate)
    elsif left == Number.zero then Number.zero
    elsif right == Number.zero then Number.zero
    elsif left == Number.one then right.simplify
    elsif right == Number.one then left.simplify
    else super
    end
  end

  def derivative(var)
    left.derivative(var) * right + left * right.derivative(var)
  end

  def to_s
    "(#{left} * #{right})"
  end
end

class Variable < Unary
  def evaluate(env = {})
    env.fetch expr
  end

  def simplify
    self
  end

  def derivative(var)
    var == @expr ? Number.one : Number.zero
  end

  def exact?
    false
  end

  def to_s
    expr.to_s
  end
end

class Negation < Unary
  def evaluate(env = {})
    -expr.evaluate(env)
  end

  def simplify
    if exact?
      Number.new(-expr.simplify.evaluate)
    else
      Negation.new(expr.simplify)
    end
  end

  def derivative(var)
    Negation.new expr.derivative(var)
  end

  def exact?
    expr.exact?
  end

  def to_s
    "-#{expr}"
  end
end

class Sine < Unary
  def evaluate(env = {})
    Math.sin expr.evaluate(env)
  end

  def simplify
    if exact?
      Number.new Math.sin(expr.simplify.evaluate)
    else
      Sine.new expr.simplify
    end
  end

  def derivative(var)
    expr.derivative(var) * Cosine.new(expr)
  end

  def to_s
    "sin(#{expr})"
  end
end

class Cosine < Unary
  def evaluate(env = {})
    Math.cos expr.evaluate(env)
  end

  def simplify
    if exact?
      Number.new Math.cos(expr.simplify.evaluate)
    else
      Cosine.new expr.simplify
    end
  end

  def derivative(var)
    expr.derivative(var) * -Sine.new(expr)
  end

  def to_s
    "cos(#{expr})"
  end
end

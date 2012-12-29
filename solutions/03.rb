class Expr
  def self.build expression
    if expression[0] == :number
      Number.new expression[1]
    elsif expression.size == 2
        Unary.build expression
    else
        Binary.build expression
    end
  end
end

class Number < Expr
  attr_reader :argument

  def initialize argument
    @argument = argument
  end

  def == expression
    if not expression.is_a? Number
      return false
    end
    @argument == expression.argument
  end

  def evaluate _ = {}
    self.argument
  end

  def simplify
    self
  end

  def + expression
    if argument == 0
      return expression
    end
    if expression.is_a? Number
      return Number.new( argument + expression.argument)
    end
    return Addition.new self, expression
  end

  def * expression
    if argument == 0
      return Number.new 0
    elsif argument == 1
      return expression
    end
    if expression.is_a? Number
      return Number.new( argument * expression.argument)
    end
    return Multiplication.new self, expression
  end

  def derive _
    Number.new 0
  end
end


class Unary < Expr
  attr_reader :argument

  def initialize argument
    @argument = argument
  end

  def == expression
    if not expression.class == self.class
      return false
    end
    @argument == expression.argument
  end

  def + expression
    if expression.is_a? Number and expression.evaluate == 0
      return self
    end
    return Addition.new self, expression
  end

  def * expression
    if expression.is_a? Number and expression.evaluate == 0
        return Number.new 0
    elsif expression.is_a? Number and expression.evaluate == 1
        return self
    end
    return Multiplication.new self, expression
  end

  def self.build expression
    case expression[0]
      when :variable
        Variable.new expression[1]
      when :-
        Negation.new Expr.build expression[1]
      when :sin
        Sine.new Expr.build expression[1]
      when :cos
        Cosine.new Expr.build expression[1]
    end
  end
end


class Variable < Unary
  def evaluate context = {}
    if not context.has_key? argument
      raise "the context #{ context.inspect } does not contains the variable: #{ self.inspect }"
    end
    context[argument]
  end

  def simplify
    self
  end

  def derive variable
    if variable == argument
      return Number.new 1
    end
    return Number.new 0
  end
end


class Sine < Unary
  def evaluate context = {}
    Math.sin argument.evaluate(context)
  end

  def simplify
    argument_simplified = argument.simplify
    if argument_simplified.is_a? Number
      return Math.sin( argument_simplified.evaluate )
    end
    Sine.new argument_simplified
  end

  def derive variable
    Multiplication.new( Cosine.new( argument ), argument.derive( variable ) ).simplify
  end
end


class Cosine < Unary
  def initialize argument
    @argument = argument
  end

  def evaluate context = {}
    Math.cos argument.evaluate(context)
  end

  def simplify
    argument_simplified = argument.simplify
    if argument_simplified.is_a? Number
      return Math.cos( argument_simplified.evaluate )
    end
    Cosine.new argument_simplified
  end

  def derive variable
    Negation.new( Multiplication.new( Sine.new( argument ), argument.derive( variable ) ) ).simplify
  end
end


class Negation < Unary
  def evaluate context = {}
    return -1 * argument.evaluate( context )
  end

  def simplify
    argument_simplified = argument.simplify
    if argument_simplified.is_a? Number
      return Number.new( -1 * argument_simplified.evaluate )
    end
    Negation.new argument_simplified
  end

  def derive variable
    return Negation.new( argument.derive variable ).simplify
  end
end


class Binary < Expr
  attr_reader :left_argument, :right_argument

  def initialize left_argument, right_argument
    @left_argument = left_argument
    @right_argument = right_argument
  end

  def == expression
    if not expression.class == self.class
      return false
    end
    left_argument == expression.left_argument and right_argument == expression.right_argument
  end

  def + expression
    if expression.is_a? Number and expression.evaluate == 0
      return self
    end
    return Addition.new self, expression
  end

  def * expression
    if expression.is_a? Number and expression.evaluate == 0
        return Number.new 0
    elsif expression.is_a? Number and expression.evaluate == 1
        return self
    end
    return Multiplication.new self, expression
  end

  def self.build expression
    case expression[0]
      when :+
        Addition.new Expr.build( expression[1] ), Expr.build( expression[2] )
      when :*
        Multiplication.new Expr.build( expression[1] ), Expr.build( expression[2] )
    end
  end
end


class Addition < Binary
  def evaluate context = {}
    return left_argument.evaluate( context ) + right_argument.evaluate( context )
  end

  def simplify
    return left_argument.simplify + right_argument.simplify
  end

  def derive variable
    Addition.new( left_argument.derive( variable ), right_argument.derive( variable ) ).simplify
  end
end


class Multiplication < Binary
  def evaluate context = {}
    return left_argument.evaluate( context ) * right_argument.evaluate( context )
  end

  def simplify
    return left_argument.simplify * right_argument.simplify
  end

  def derive variable
    left_derivative = Multiplication.new( left_argument.derive( variable ), right_argument )
    right_derivative = Multiplication.new( left_argument, right_argument.derive( variable ) )
    Addition.new( left_derivative, right_derivative ).simplify
  end
end
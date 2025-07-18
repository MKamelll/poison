require_relative 'lexer'

class Expression
  def initialize(*args) end
end

class PrimaryExpr < Expression
  attr_accessor :value

  def initialize(value)
    @value = value
  end
end

class IntExpr < PrimaryExpr
  def to_s
    "IntExpr(#{@value})"
  end
end

class FloatExpr < PrimaryExpr
  def to_s
    "FloatExpr(#{@value})"
  end
end

class StringExpr < PrimaryExpr
  def to_s
    "StringExpr(#{@value})"
  end
end

class IdentifierExpr < PrimaryExpr
  def to_s
    "Identifier(#{@value})"
  end
end

class LetExpr < Expression
  def initialize(identifier, expr)
    super(identifier, expr)
    @identifier = identifier
    @expr = expr
  end

  def to_s
    "LetExpr(identifier: #{@identifier}, expr: #{@expr})"
  end
end

class ConstExpr < Expression
  def initialize(identifier, expr)
    super(identifier, expr)
    @identifier = identifier
    @expr = expr
  end

  def to_s
    "ConstExpr(identifier: #{@identifier}, expr: #{@expr})"
  end
end

class BlockExpr < Expression
  def initialize(exprs)
    super(exprs)
    @exprs = exprs
  end

  def to_s
    "BlockExpr(exprs: #{@exprs})"
  end
end

class BinaryExpr < Expression
  attr_accessor :lhs, :op, :rhs

  def initialize(lhs, operator, rhs)
    super(lhs, operator, rhs)
    @lhs = lhs
    @operator = operator
    @rhs = rhs
  end

  def to_s
    "BinaryExpr(lhs: #{@lhs}, operator: #{@operator}, rhs: #{@rhs})"
  end
end

class Operator
  attr_accessor :op, :associativity, :precedence

  def initialize(operator, precedence, associativity)
    @operator = operator
    @precedence = precedence
    @associativity = associativity
  end

  def to_s
    "Operator('#{@operator}')"
  end
end

class Parser
  def initialize(lexer)
    @lexer = lexer
    @curr_token = lexer.next
    @prev_token = @curr_token
    @parsed_trees = []
    @allowed_ops = {
      'or' => Operator.new('or', 0, :left),
      'and' => Operator.new('and', 0, :left),
      'not' => Operator.new('not', 0, :left),

      '==' => Operator.new('==', 0, :left),
      '<' => Operator.new('<', 1, :left),
      '<=' => Operator.new('<=', 1, :left),
      '>' => Operator.new('>', 1, :left),
      '>=' => Operator.new('>', 1, :left),

      '+' => Operator.new('+', 6, :left),
      '-' => Operator.new('-', 6, :left),
      '*' => Operator.new('*', 7, :left),
      '/' => Operator.new('/', 7, :left),
      '^' => Operator.new('^', 8, :right)
    }
  end

  def advance
    @prev_token = @curr_token
    @curr_token = @lexer.next
  end

  def match(*types)
    types.each do |t|
      if @curr_token.type == t
        advance
        return true
      end
    end
    false
  end

  def expected(what)
    raise "Expected '#{what}' instead got #{prev.lexeme}"
  end

  def prev
    @prev_token
  end

  def curr
    @curr_token
  end

  def at_end?
    @curr_token.type == :eof
  end

  def parse
    return @parsed_trees if at_end?

    expr = parse_expr
    @parsed_trees << expr

    parse
  end

  def parse_expr(min_precedence = 0)
    lhs = parse_primary
    until at_end?
      op = curr.lexeme
      allowed_op = @allowed_ops.key?(op)
      break if !allowed_op || @allowed_ops[op].precedence < min_precedence

      curr_op = @allowed_ops[op]
      next_min_precedence = curr_op.precedence

      next_min_precedence += 1 if curr_op.associativity == :right
      advance
      rhs = parse_expr(next_min_precedence)
      lhs = BinaryExpr.new(lhs, op, rhs)
    end

    lhs
  end

  def parse_primary
    parse_int
  end

  def parse_int
    return IntExpr.new(prev.lexeme) if match(:int)

    parse_float
  end

  def parse_float
    return FloatExpr.new(prev.lexeme) if match(:float)

    parse_string
  end

  def parse_string
    return StringExpr.new(prev.lexeme) if match(:string)

    parse_identifier
  end

  def parse_identifier
    IdentifierExpr.new(prev.lexeme) if match(:identifier)
    parse_let_expr
  end

  def parse_let_expr
    if match(:let)
      expected(:identifier) unless match(:identifier)
      identifier = prev.lexeme
      expected('=') unless match(:equal)
      rhs = parse_expr
      expected(';') unless match(:semi_colon)
      return LetExpr.new(identifier, rhs)
    end
    parse_const_expr
  end

  def parse_const_expr
    if match(:const)
      expected(:identifier) unless match(:identifier)
      identifier = prev.lexeme
      expected('=') unless match(:equal)
      rhs = parse_expr
      expected(';') unless match(:semi_colon)
      return ConstExpr.new(identifier, rhs)
    end
    parse_block_expr
  end

  def parse_block_expr
    if match(:left_bracket)
      exprs = []
      until at_end?
        break if curr.type == :right_bracket

        exprs << parse_expr
      end
      expected('}') unless match(:right_bracket)
      return BlockExpr.new(exprs)
    end
    illegal
  end

  def illegal
    raise "Expected a primary token instead got '#{curr.lexeme}'"
  end
end

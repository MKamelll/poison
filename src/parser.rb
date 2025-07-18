require_relative 'lexer'

class Expression
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

class BinaryExpr < Expression
  attr_accessor :lhs, :op, :rhs

  def initialize(lhs, operator, rhs)
    super
    @lhs = lhs
    @operator = operator
    @rhs = rhs
  end

  def to_s
    "BinaryExpr(lhs: #{@lhs}, operator: #{@operator}, rhs: #{@rhs})"
  end
end

class Parser
  def initialize(lexer)
    @lexer = lexer
    @curr_token = lexer.next
    @prev_token = @curr_token
    @parsed_trees = []
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

  def parse_expr
    parse_primary
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
    return IdentifierExpr.new(prev.lexeme) if match(:identifier)

    raise "Expected a primary token instead got '#{curr.lexeme}'"
  end
end

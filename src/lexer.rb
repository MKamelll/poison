class Token
  attr_accessor :type, :lexeme

  def initialize(type:, lexeme:)
    @type = type
    @lexeme = lexeme
  end

  def to_s
    "Token(type: #{@type}, lexeme: '#{@lexeme}')"
  end
end

class Lexer
  def initialize(source)
    @source = source
    @curr_index = 0
  end

  def is_at_end
    @curr_index >= @source.length
  end

  def advance
    @curr_index += 1
  end

  def curr
    @source[@curr_index]
  end

  def next
    return Token.new(type: :eof, lexeme: 'eof') if is_at_end

    case curr
    when '('
      advance
      return Token.new(type: :left_paren, lexeme: '(')
    when ')'
      advance
      return Token.new(type: :right_paren, lexeme: ')')
    when '['
      advance
      return Token.new(type: :left_brace, lexeme: '[')
    when ']'
      advance
      return Token.new(type: :right_brace, lexeme: ']')
    when '{'
      advance
      return Token.new(type: :left_bracket, lexeme: '{')
    when '}'
      advance
      return Token.new(type: :right_bracket, lexeme: '}')
    when '+'
      advance
      if curr == '+'
        advance
        return Token.new(type: :plus_plus, lexeme: '++')
      elsif curr == '='
        advance
        return Token.new(type: :plus_equal, lexeme: '+=')
      end
      return Token.new(type: :plus, lexeme: '+')
    when '-'
      advance
      if curr == '-'
        advance
        return Token.new(type: :minus_minus, lexeme: '--')
      elsif curr == '='
        advance
        return Token.new(type: :minus_equal, lexeme: '-=')
      end
      return Token.new(type: :minus, lexeme: '-')
    when '*'
      advance
      if curr == '*'
        advance
        return Token.new(type: :star_star, lexeme: '**')
      elsif curr == '='
        advance
        return Token.new(type: :star_equal, lexeme: '*=')
      end
      return Token.new(type: :star, lexeme: '*')
    when '/'
      advance
      if curr == '='
        advance
        return Token.new(type: :slash_equal, lexeme: '/=')
      end
      return Token.new(type: :slash, lexeme: '/')
    when '='
      advance
      if curr == '='
        advance
        return Token.new(type: :equal_equal, lexeme: '==')
      end
      return Token.new(type: :equal, lexeme: '=')
    when '>'
      advance
      if curr == '='
        advance
        return Token.new(type: :greater_than_equal, lexeme: '>=')
      end
      return Token.new(type: :greater_than, lexeme: '>')
    when '<'
      advance
      if curr == '='
        advance
        return Token.new(type: :less_than_equal, lexeme: '<=')
      end
      return Token.new(type: :less_than, lexeme: '<')
    when ';'
      advance
      return Token.new(type: :semi_colon, lexeme: ';')
    when ':'
      advance
      return Token.new(type: :colon, lexeme: ':')
    when '"'
      advance
      string = ''
      until is_at_end
        break if curr == '"'

        string << curr
        advance
      end
      advance
      return Token.new(type: :string, lexeme: string)
    when '0'..'9'
      number = ''
      is_float = false
      until is_at_end
        if curr == '.'
          is_float = true
          number << '.'
          advance
        end
        break unless ('0'..'9').include?(curr)

        number << curr
        advance
      end
      return Token.new(type: :float, lexeme: number) if is_float

      return Token.new(type: :int, lexeme: number)
    when 'a'..'z', 'A'..'Z'
      identifier = ''
      identifier << curr
      advance
      until is_at_end
        if ('a'..'z').include?(curr) || ('A'..'Z').include?(curr) || ('0'..'9').include?(curr)
          identifier << curr
          advance
          next
        end
        break
      end
      case identifier
      when 'for'
        return Token.new(type: :for, lexeme: 'for')
      when 'while'
        return Token.new(type: :while, lexeme: 'while')
      when 'if'
        return Token.new(type: :if, lexeme: 'if')
      when 'else'
        return Token.new(type: :else, lexeme: 'else')
      when 'function'
        return Token.new(type: :function, lexeme: 'function')
      when 'return'
        return Token.new(type: :return, lexeme: 'return')
      when 'let'
        return Token.new(type: :let, lexeme: 'let')
      when 'const'
        return Token.new(type: :const, lexeme: 'const')
      when 'class'
        return Token.new(type: :class, lexeme: 'class')
      end
      return Token.new(type: :identifier, lexeme: identifier)
    when ' '
      advance
      return self.next
    end
    illegal_token = curr
    advance
    Token.new(type: :illegal_token, lexeme: illegal_token)
  end
end

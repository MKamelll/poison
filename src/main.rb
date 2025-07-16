require_relative 'lexer'

test = '() {} [] function let const "string" 15 12.154 for while return variable'
lexer = Lexer.new source: test
token = lexer.next
until token.type == :eof
  puts token
  token = lexer.next
end

puts token

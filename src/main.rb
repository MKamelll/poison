require_relative 'lexer'
require_relative 'parser'

version = '0.1.0'

puts "welcome to poison #{version}"
loop do
  print '> '
  line = gets.chomp
  break if line.length <= 0 || line == ':q'

  lexer = Lexer.new line
  parser = Parser.new lexer

  begin
    puts parser.parse
  rescue StandardError => e
    puts e.message
  end
end

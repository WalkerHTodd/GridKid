require 'test/unit'
require_relative 'Lexer.rb'
require_relative 'Token.rb'
require_relative 'Parser.rb'
require_relative 'Primatives.rb'
require_relative 'Arithmetic.rb'
require_relative 'Serializer.rb'
require_relative 'Evaluator.rb'
require_relative 'Logical.rb'
require_relative 'Cell.rb'

module TestingMilestone2
    class TestLexer < Test::Unit::TestCase
      def setup
        @serializer = Serializer.new
        @evaluator = Evaluator.new
        @runtime = Runtime.new(10, 10)
      end

      def test_ifstatements
        lexed = Lexer.new("if (5 < 10) 5 end else 10 end").lex
        parsed = Parser.new(lexed, @runtime).parse
        parseded = parsed.traverse(@evaluator, @runtime)
        parseded.each do |x|
         assert_equal(5, x.value)
        end
      end

      def test_forloops

        lexed = Lexer.new("for value in #[4, 0]..#[4, 3] do value end").lex
        cell1 = Primatives::CellAddress.new(4, 0)
        @runtime.grid.set_cell(cell1, Primatives::IntegerMine.new(10))
        cell2 = Primatives::CellAddress.new(4, 1)
        @runtime.grid.set_cell(cell2, Primatives::IntegerMine.new(20))
        cell3 = Primatives::CellAddress.new(4, 2)
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(30))
        cell4 = Primatives::CellAddress.new(4, 3)
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(40))
        parsed = Parser.new(lexed, @runtime).parse
        parseded = parsed.traverse(@evaluator, @runtime)
        puts lexed.inspect
        puts parseded.inspect
      end 
    end
end


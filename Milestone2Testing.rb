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

      def test_milestone2_goals
        p "--------------------------------------------"
        p "(5 + 2) * 3 % 4"
        # Arithmetic: (5 + 2) * 3 % 4 - Works
        lexer1 = Lexer.new("(5 + 2) * 3 % 4")
        tokens1 = lexer1.lex
        tokens1.each do |token|
          p token.type
          p token.value
        end
        parser1 = Parser.new(tokens1)
        parsed = parser1.parse
        actual = parsed.traverse(@evaluator, @runtime)
        assert_equal 1, actual.value

        p "--------------------------------------------"
        p  "#[0, 0] + 3"

        cell1 = Primatives::CellAddress.new(0, 0)
        @runtime.grid.set_cell(cell1, Primatives::IntegerMine.new(1))

        # Rvalue lookup and shift: #[0, 0] + 3 - Works
        expression = "#[0, 0] + 3"
        lexer = Lexer.new(expression)
        tokens = lexer.lex
        tokens.each do |token|
          p token.type
          p token.value
        end
        par1 = Parser.new(tokens).parse
        actual = par1.traverse(@evaluator, @runtime)
        assert_equal(4, actual.value)
        p "--------------------------------------------"
        p  "#[1 - 1, 0] < #[1 * 1, 1]"

        cell2 = Primatives::CellAddress.new(1, 1)
        @runtime.grid.set_cell(cell2, Primatives::IntegerMine.new(3))
        # # Rvalue lookup and comparison: #[1 - 1, 0] < #[1 * 1, 1]
        expression = "#[1 - 1, 0] < #[1 * 1, 1]"
        lexer = Lexer.new(expression)
        tokens = lexer.lex
        tokens.each do |token|
          p token.type
          p token.value
        end
        par = Parser.new(tokens)
        parsed = par.parse
        traversed = parsed.traverse(@evaluator, @runtime)
        assert_equal(true, traversed.value)
        p "--------------------------------------------"
        p  "(5 > 3) && !(2 > 8)"


        # Logic and comparison: (5 > 3) && !(2 > 8)
        expression = "(5 > 3) && !(2 > 8)"
        lexer = Lexer.new(expression)
        tokens = lexer.lex
        tokens.each do |token|
          p token.type
          p token.value
        end
        par = Parser.new(tokens)
        parsed = par.parse
        traversed = parsed.traverse(@evaluator, @runtime)
        assert_equal(true, traversed.value)

        p "--------------------------------------------"
        p  "Sum: 1 + sum([0, 0], [2, 1])"


        # Sum: 1 + sum([0, 0], [2, 1])
        cell1 = Primatives::CellAddress.new(0, 0)
        @runtime.grid.set_cell(cell1, Primatives::IntegerMine.new(1))
        cell2 = Primatives::CellAddress.new(2, 1)
        @runtime.grid.set_cell(cell2, Primatives::IntegerMine.new(3))
        cell3 = Primatives::CellAddress.new(1, 1)
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        cell4 = Primatives::CellAddress.new(1, 0)
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(3))
        expression = "1 + sum([0, 0], [2, 1])"
        lexer = Lexer.new(expression)
        tokens = lexer.lex
        tokens.each do |token|
          p token.type
          p token.value
        end
        par = Parser.new(tokens)
        parsed = par.parse
        traversed = parsed.traverse(@evaluator, @runtime)
        assert_equal(11, traversed.value)
        
        p "--------------------------------------------"
        p "float(10) / 4.0"
        # Casting: float(10) / 4.0
        expression = "float(10) / 4.0"
        lexer = Lexer.new(expression)
        tokens = lexer.lex
        tokens.each do |token|
          p token.type
          p token.value
        end
        par = Parser.new(tokens)
        parsed = par.parse
        traversed = parsed.traverse(@evaluator, @runtime)
        assert_equal(2.5, traversed.value)
      end

      # def test_errors
      #   p "--------------------------------------------"
      #   p "Error: 1 + 2 +"
      #   # Error: 1 + 2 +
      #   expression = "1 + 2 +"
      #   lexer = Lexer.new(expression)
      #   tokens = lexer.lex
      #   tokens.each do |token|
      #     p token.type
      #     p token.value
      #   end
      #   par = Parser.new(tokens)
      #   assert_raise(RuntimeError) { par.parse }

      # end


      def test_parser
        expression = "1 + 2"
        lexer = Lexer.new(expression)
        tokens = lexer.lex
        par = Parser.new(tokens)
      
        parsed = par.expression
        traversed = parsed.traverse(@evaluator, @runtime) 
      
        assert_equal(3, traversed.value)

        expression = "1 + 2 * 3"
        lexer = Lexer.new(expression)
        tokens = lexer.lex
        par = Parser.new(tokens)
        
        parsed = par.expression
        traversed = parsed.traverse(@evaluator, @runtime)
        assert_equal(7, traversed.value)

        # expression = "[1 + 2, 3]"
        # lexer = Lexer.new(expression)
        # tokens = lexer.lex
        # par = Parser.new(tokens)

        # parsed = par.expression
        # traversed = parsed.traverse(@evaluator, @runtime)
        # assert_equal([3, 3], traversed)


      end
      
      # if I forget to change this I know the tests arnt being run :)
      def lexer_tests
        lexer = Lexer.new("1 + 2").lex
        lexer.each do |token|
          p token.type
          p token.value
        end
        puts "-----------------"
        lexer = Lexer.new("#[1, 2 + 2]").lex
        lexer.each do |token|
          p token.type
          p token.value
        end
        puts "-----------------"
        lexer = Lexer.new("1 + 2 * 3").lex
        lexer.each do |token|
          p token.type
          p token.value
        end
        puts "-----------------"
        lexer = Lexer.new("[1 + 2, 3]").lex
        lexer.each do |token|
          p token.type
          p token.value
        end
        puts "-----------------"
        lexer = Lexer.new("Sum([1 + 3, 3], [1,3])").lex
        lexer.each do |token|
          p token.type
          p token.value
        end
      end
    end
  end
  
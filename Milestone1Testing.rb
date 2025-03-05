require 'test/unit'
require_relative 'Primatives.rb'
require_relative 'Arithmetic.rb'
require_relative 'Serializer.rb'
require_relative 'Evaluator.rb'
require_relative 'Logical.rb'
require_relative 'Cell.rb'
require_relative 'Relational.rb'
require_relative 'Bitwise.rb'
require_relative 'Statistical.rb'
require_relative 'Casting.rb'

include Primatives
include Arithmetic
include Logical
include Cell
include Relational
include Bitwise
include Statistical
include Casting

module Testing
  class TestPrimatives < Test::Unit::TestCase

    def setup
        @serializer = Serializer.new
        @evaluator = Evaluator.new
        @runtime = Runtime.new(10, 10)
    end      

    def test_milestone1
        # Arithmetic: (7 * 4 + 3) % 12
        int1 = Primatives::IntegerMine.new(7)
        int2 = Primatives::IntegerMine.new(4)
        int3 = Primatives::IntegerMine.new(3)
        int4 = Primatives::IntegerMine.new(12)
        expression = Modulus.new(Addition.new(Multiplication.new(int1, int2), int3), int4)        
        actual = expression.traverse(@serializer, @runtime)
        expected = "(7 * 4 + 3) % 12"
        assert_equal expected, actual
        # Evaluate
        actual_evalutate = expression.traverse(@evaluator, @runtime)
        expected_evaluate = 7
        assert_equal expected_evaluate, actual_evalutate.value

        #Rvalue lookup and shift: #[1 + 1, 4] << 3
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(1)
        int3 = Primatives::IntegerMine.new(4)
        int4 = Primatives::IntegerMine.new(3)
        expression = Bitwise::LeftShift.new(Cell::RightValueCell.new(Arithmetic::Addition.new(int1, int2), int3), int4)
        actual = expression.traverse(@serializer, @runtime)
        expected = "#[(1 + 1), 4] << 3"
        assert_equal expected, actual

        # Evaluate
        cell1 = Primatives::CellAddress.new(2, 4)
        @runtime.grid.set_cell(cell1, Primatives::IntegerMine.new(10))
        actual = expression.traverse(@evaluator, @runtime)
        expected = 80
        assert_equal expected, actual.value
    
        #Rvalue lookup and comparison: #[0, 0] < #[0, 1]
        int1 = Primatives::IntegerMine.new(0)
        int2 = Primatives::IntegerMine.new(0)
        int3 = Primatives::IntegerMine.new(0)
        int4 = Primatives::IntegerMine.new(1)
        expression = Relational::LessThan.new(Cell::RightValueCell.new(int1, int2), Cell::RightValueCell.new(int3, int4))
        actual = expression.traverse(@serializer, @runtime)
        expected = "(#[0, 0] < #[0, 1])"
        assert_equal expected, actual
        #Evaluate
        cell1 = Primatives::CellAddress.new(0, 0)
        cell2 = Primatives::CellAddress.new(0, 1)
        @runtime.grid.set_cell(cell1, Primatives::IntegerMine.new(1))
        @runtime.grid.set_cell(cell2, Primatives::IntegerMine.new(2))
        actual = expression.traverse(@evaluator, @runtime)
        expected = true
        assert_equal expected, actual.value

        #Logic and comparison: !(3.3 > 3.2)
        int1 = Primatives::FloatMine.new(3.3)
        int2 = Primatives::FloatMine.new(3.2)
        expression = Logical::Not.new(Relational::GreaterThan.new(int1, int2))
        actual = expression.traverse(@serializer, @runtime)
        expected = "!((3.3 > 3.2))"
        assert_equal expected, actual
        #Evaluate
        actual = expression.traverse(@evaluator, @runtime)
        expected = false
        assert_equal expected, actual.value

        #Sum: sum([1, 2], [5, 3])
        int1 = Primatives::CellAddress.new(1, 2)
        int2 = Primatives::CellAddress.new(5, 3)
        expression = Statistical::Sum.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime)
        expected = "sum([1, 2], [5, 3])"
        assert_equal expected, actual

        #Evaluate
        cell1 = Primatives::CellAddress.new(1, 2)
        cell2 = Primatives::CellAddress.new(5, 3)
        cell3 = Primatives::CellAddress.new(1, 3)
        cell4 = Primatives::CellAddress.new(5, 2)
        cell5 = Primatives::CellAddress.new(3, 3)
        cell7 = Primatives::CellAddress.new(3, 2)
        cell8 = Primatives::CellAddress.new(4, 3)
        @runtime.grid.set_cell(cell1, Primatives::IntegerMine.new(1))
        @runtime.grid.set_cell(cell2, Primatives::IntegerMine.new(2))
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(4))
        @runtime.grid.set_cell(cell5, Primatives::IntegerMine.new(5))
        @runtime.grid.set_cell(cell7, Primatives::IntegerMine.new(7))
        @runtime.grid.set_cell(cell8, Primatives::IntegerMine.new(8))
        actual = expression.traverse(@evaluator, @runtime)
        expected = Primatives::IntegerMine.new(30)
        assert_equal expected.value, actual.value
        
        #Casting: float(7) / 2
        int1 = Primatives::IntegerMine.new(7)
        int2 = Primatives::IntegerMine.new(2)
        int_to_float = Casting::IntToFloatMine.new(int1)

        expression = Arithmetic::Division.new(int_to_float, int2)
        actual = expression.traverse(@serializer, @runtime)
        expected = "(float(7) / 2)"
        assert_equal expected, actual

        #Evaluate
        actual = expression.traverse(@evaluator, @runtime)
        expected = 3.5
        assert_equal expected, actual.value
    end

    def test_integer_serializer
        int1 = Primatives::IntegerMine.new(1)
        actual = int1.traverse(@serializer, @runtime)
        expected = "1"
        assert_equal expected, actual
    end

    def test_float_serializer
        int1 = Primatives::FloatMine.new(1.5)
        actual = int1.traverse(@serializer, @runtime)
        expected = "1.5"
        assert_equal expected, actual
    end

    def test_boolean_serializer
        int1 = Primatives::Boolean.new(true)
        actual = int1.traverse(@serializer, @runtime)
        expected = "true"
        assert_equal expected, actual
    end

    def test_string_serializer
        int1 = Primatives::StringMine.new("Walker")
        actual = int1.traverse(@serializer, @runtime)
        expected = "Walker"
        assert_equal expected, actual
    end

    def test_cell_serializer
        int1 = Primatives::CellAddress.new(1, 1)
        actual = int1.traverse(@serializer, @runtime)
        expected = "[1, 1]"
        assert_equal expected, actual
    end

    def test_add_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Addition.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 3
        assert_equal expected, actual.value
    end

    def test_add_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Addition.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 + 2)"
        assert_equal expected, actual
    end

    def test_subtract_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Subtraction.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = -1
        assert_equal expected, actual.value
    end
    
    def test_subtract_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Subtraction.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 - 2)"
        assert_equal expected, actual
    end

    def test_multiply_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Multiplication.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 2
        assert_equal expected, actual.value
    end

    def test_multiply_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Multiplication.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "1 * 2"
        assert_equal expected, actual
    end

    def test_divide_evaluator
        # 1 float
        int1 = Primatives::FloatMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Division.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 0.5
        assert_equal expected, actual.value

        # 2 integers
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Division.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime)
        expected = 0
        assert_equal expected, actual.value
    end

    def test_divide_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Division.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 / 2)"
        assert_equal expected, actual
    end

    def test_exponentiation_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Exponentiation.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 1
        assert_equal expected, actual.value

        int1 = Primatives::IntegerMine.new(2)
        int2 = Primatives::FloatMine.new(2.7)
        expression = Arithmetic::Exponentiation.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime)
        expected = 6.498
        assert_equal expected, actual.value
    end

    def test_exponentiation_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Exponentiation.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 ** 2)"
        assert_equal expected, actual
    end

    def test_modulus_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Modulus.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 1
        assert_equal expected, actual.value
    end

    def test_modulus_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Modulus.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "1 % 2"
        assert_equal expected, actual
    end

    """
    Logical Operations
    """

    def test_negation_evaluator
        int1 = Primatives::IntegerMine.new(1)
        expression = Arithmetic::Negation.new(int1)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = -1
        assert_equal expected, actual.value
    end

    def test_negation_serializer
        int1 = Primatives::IntegerMine.new(1)
        expression = Arithmetic::Negation.new(int1)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "-(1)"
        assert_equal expected, actual
    end

    def test_lessThan_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Relational::LessThan.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = true
        assert_equal expected, actual.value
    end

    def test_lessThan_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Relational::LessThan.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 < 2)"
        assert_equal expected, actual
    end

    def test_greaterThan_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Relational::GreaterThan.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = false
        assert_equal expected, actual.value
    end

    def test_greaterThan_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Relational::GreaterThan.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 > 2)"
        assert_equal expected, actual
    end

    def test_and_evaluator
        bool1 = Primatives::Boolean.new(true)
        bool2 = Primatives::Boolean.new(false)
        expression = Logical::And.new(bool1, bool2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = false
        assert_equal expected, actual.value
    end

    def test_and_serializer
        bool1 = Primatives::Boolean.new(true)
        bool2 = Primatives::Boolean.new(false)
        expression = Logical::And.new(bool1, bool2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(true && false)"
        assert_equal expected, actual
    end

    def test_or_evaluator
        bool1 = Primatives::Boolean.new(true)
        bool2 = Primatives::Boolean.new(false)
        expression = Logical::Or.new(bool1, bool2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = true
        assert_equal expected, actual.value
    end

    def test_or_serializer
        bool1 = Primatives::Boolean.new(true)
        bool2 = Primatives::Boolean.new(false)
        expression = Logical::Or.new(bool1, bool2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(true || false)"
        assert_equal expected, actual
    end

    def test_not_evaluator
        bool1 = Primatives::Boolean.new(true)
        expression = Logical::Not.new(bool1)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = false
        assert_equal expected, actual.value
    end

    def test_not_serializer
        bool1 = Primatives::Boolean.new(true)
        expression = Logical::Not.new(bool1)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "!(true)"
        assert_equal expected, actual
    end

    def test_bitwiseAnd_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::BitwiseAnd.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 0
        assert_equal expected, actual.value
    end

    def test_bitwiseAnd_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::BitwiseAnd.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 & 2)"
        assert_equal expected, actual
    end

    def test_bitwiseOr_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::BitwiseOr.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 3
        assert_equal expected, actual.value
    end

    def test_bitwiseOr_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::BitwiseOr.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 | 2)"
        assert_equal expected, actual
    end

    def test_bitwiseNot_evaluator
        int1 = Primatives::IntegerMine.new(1)
        expression = Bitwise::BitwiseNot.new(int1)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = -2
        assert_equal expected, actual.value
    end

    def test_bitwiseNot_serializer
        int1 = Primatives::IntegerMine.new(1)
        expression = Bitwise::BitwiseNot.new(int1)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "~(1)"
        assert_equal expected, actual
    end

    def test_bitwiseXor_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::Xor.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 3
        assert_equal expected, actual.value
    end

    def test_bitwiseXor_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::Xor.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "(1 ^ 2)"
        assert_equal expected, actual
    end

    def test_leftShift_evaluator
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::LeftShift.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 4
        assert_equal expected, actual.value
    end

    def test_leftShift_serializer
        int1 = Primatives::IntegerMine.new(1)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::LeftShift.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "1 << 2"
        assert_equal expected, actual
    end

    def test_rightShift_evaluator
        int1 = Primatives::IntegerMine.new(4)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::RightShift.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 1
        assert_equal expected, actual.value
    end

    def test_rightShift_serializer
        int1 = Primatives::IntegerMine.new(4)
        int2 = Primatives::IntegerMine.new(2)
        expression = Bitwise::RightShift.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime) 
        expected = "4 >> 2"
        assert_equal expected, actual
    end

    def test_LeftValueCell_evaluator
        expression = Cell::LeftValueCell.new(IntegerMine.new(1), IntegerMine.new(1))
        actual = expression.traverse(@evaluator, @runtime)
        expected = Primatives::CellAddress.new(1, 1)
        assert_equal expected.row, actual.row
        assert_equal expected.column, actual.column
    end

    def test_LeftValueCell_serializer
        expression = Cell::LeftValueCell.new(IntegerMine.new(1), IntegerMine.new(1))
        actual = expression.traverse(@serializer, @runtime)
        expected = "[1, 1]"
        assert_equal expected, actual
    end

    def test_RightValueCell_evaluator
        @runtime.grid.set_cell(CellAddress.new(1,1), Primatives::IntegerMine.new(10))
        expression = Cell::RightValueCell.new(IntegerMine.new(1), IntegerMine.new(1))
        actual = expression.traverse(@evaluator, @runtime)
        expected = 10
        assert_equal expected, actual.value
        
    end

    def test_RightValueCell_serializer
        expression = Cell::RightValueCell.new(IntegerMine.new(1), IntegerMine.new(1))
        actual = expression.traverse(@serializer, @runtime)
        expected = "#[1, 1]"
        assert_equal expected, actual
    end


    def test_sum_evaluator
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        cell3 = Primatives::CellAddress.new(1, 2)
        cell4 = Primatives::CellAddress.new(2, 1)
        expression = Statistical::Sum.new(int1, int2)
        @runtime.grid.set_cell(int1, Primatives::IntegerMine.new(1))
        @runtime.grid.set_cell(int2, Primatives::IntegerMine.new(2))
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(4))
        actual = expression.traverse(@evaluator, @runtime)
        expected = Primatives::IntegerMine.new(10)
        assert_equal expected.value, actual.value
    end

    def test_sum_serializer

        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        expression = Statistical::Sum.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime)
        expected = "sum([1, 1], [2, 2])"
        assert_equal expected, actual
    end

    def test_sum_empty_cells
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        cell3 = Primatives::CellAddress.new(1, 2)
        cell4 = Primatives::CellAddress.new(2, 1)
        cell5 = Primatives::CellAddress.new(3, 1)
        cell6 = Primatives::CellAddress.new(3, 3)
        expression = Statistical::Sum.new(int1, cell6)
        @runtime.grid.set_cell(int1, Primatives::IntegerMine.new(1))
        @runtime.grid.set_cell(int2, Primatives::IntegerMine.new(2))
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(4))
        actual = expression.traverse(@evaluator, @runtime)
        expected = 10
        assert_equal expected, actual.value
    end

    def test_sum_floats
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        cell3 = Primatives::CellAddress.new(1, 2)
        cell4 = Primatives::CellAddress.new(2, 1)
        expression = Statistical::Sum.new(int1, int2)
        @runtime.grid.set_cell(int1, Primatives::FloatMine.new(1.5))
        @runtime.grid.set_cell(int2, Primatives::FloatMine.new(2.5))
        @runtime.grid.set_cell(cell3, Primatives::FloatMine.new(3.5))
        @runtime.grid.set_cell(cell4, Primatives::FloatMine.new(4.5))
        actual = expression.traverse(@evaluator, @runtime)
        expected = Primatives::FloatMine.new(12)
        assert_equal expected.value, actual.value
    end

    def test_mean_evaluator

        @runtime = Runtime.new(10, 10)
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        cell3 = Primatives::CellAddress.new(1, 2)
        cell4 = Primatives::CellAddress.new(2, 1)
        expression = Statistical::Mean.new(int1, int2)
        @runtime.grid.set_cell(int1, Primatives::IntegerMine.new(1))
        @runtime.grid.set_cell(int2, Primatives::IntegerMine.new(2))
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(4))
        actual = expression.traverse(@evaluator, @runtime)
        expected = Primatives::FloatMine.new(2.5)
        assert_equal expected.value, actual.value

        # one float in test to see how it does

        @runtime = Runtime.new(10, 10)
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        cell3 = Primatives::CellAddress.new(1, 2)
        cell4 = Primatives::CellAddress.new(2, 1)
        expression = Statistical::Mean.new(int1, int2)
        @runtime.grid.set_cell(int1, Primatives::FloatMine.new(1.5))
        @runtime.grid.set_cell(int2, Primatives::IntegerMine.new(2))
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(4))
        actual = expression.traverse(@evaluator, @runtime)
        assert_true actual.is_a? Primatives::FloatMine
        expected = Primatives::FloatMine.new(2.625)
        assert_equal expected.value, actual.value

        # Only integers

        @runtime = Runtime.new(10, 10)
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        cell3 = Primatives::CellAddress.new(1, 2)
        cell4 = Primatives::CellAddress.new(2, 1)
        expression = Statistical::Mean.new(int1, int2)
        @runtime.grid.set_cell(int1, Primatives::IntegerMine.new(1))
        @runtime.grid.set_cell(int2, Primatives::IntegerMine.new(2))
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(4))
        actual = expression.traverse(@evaluator, @runtime)
        expected = Primatives::FloatMine.new(2.5)
        assert_true actual.is_a? Primatives::FloatMine
        assert_equal expected.value, actual.value

    end

    def test_mean_serializer
        @runtime = Runtime.new(10, 10)
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        expression = Statistical::Mean.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime)
        expected = "mean([1, 1], [2, 2])"
        assert_equal expected, actual
    end

    def test_max_evaluator
        @runtime = Runtime.new(10, 10)
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        cell3 = Primatives::CellAddress.new(1, 2)
        cell4 = Primatives::CellAddress.new(2, 1)
        expression = Statistical::Max.new(int1, int2)
        @runtime.grid.set_cell(int1, Primatives::IntegerMine.new(1))
        @runtime.grid.set_cell(int2, Primatives::IntegerMine.new(2))
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(4))
        actual = expression.traverse(@evaluator, @runtime)
        expected = 4
        assert_equal expected, actual.value
    end

    def test_max_serializer
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        expression = Statistical::Max.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime)
        expected = "max([1, 1], [2, 2])"
        assert_equal expected, actual
    end

    def test_min_evaluator
        @runtime = Runtime.new(10, 10)
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        cell3 = Primatives::CellAddress.new(1, 2)
        cell4 = Primatives::CellAddress.new(2, 1)
        expression = Statistical::Min.new(int1, int2)
        @runtime.grid.set_cell(int1, Primatives::IntegerMine.new(1))
        @runtime.grid.set_cell(int2, Primatives::IntegerMine.new(2))
        @runtime.grid.set_cell(cell3, Primatives::IntegerMine.new(3))
        @runtime.grid.set_cell(cell4, Primatives::IntegerMine.new(4))
        actual = expression.traverse(@evaluator, @runtime)
        expected = 1
        assert_equal expected, actual.value
    end

    def test_min_serializer
        int1 = Primatives::CellAddress.new(1, 1)
        int2 = Primatives::CellAddress.new(2, 2)
        expression = Statistical::Min.new(int1, int2)
        actual = expression.traverse(@serializer, @runtime)
        expected = "min([1, 1], [2, 2])"
        assert_equal expected, actual
    end

    def test_division_float
        int1 = Primatives::FloatMine.new(2.5)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Division.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 1.25
        assert_equal expected, actual.value
    end

    def test_multiply_float
        int1 = Primatives::FloatMine.new(4.3)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Multiplication.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 8.6
        assert_equal expected, actual.value
    end

    def test_add_float
        int1 = Primatives::FloatMine.new(4.3)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Addition.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 6.3
        assert_equal expected, actual.value
    end

    def test_subtract_float
        int1 = Primatives::FloatMine.new(4.3)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Subtraction.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        assert_true actual.is_a? Primatives::FloatMine

        expected = 2.3
        assert_equal expected, actual.value
    end

    def test_exponentiation_float
        int1 = Primatives::FloatMine.new(4.3)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Exponentiation.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        assert_true actual.is_a? Primatives::FloatMine
        expected = 18.49
        assert_equal expected, actual.value
    end 
    
    def test_modulus_float
        int1 = Primatives::FloatMine.new(4.3)
        int2 = Primatives::IntegerMine.new(2)
        expression = Arithmetic::Modulus.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        assert_true actual.is_a? Primatives::FloatMine
        expected = 0.3
        assert_equal expected, actual.value
    end

    def test_lessThan_float
        int1 = Primatives::FloatMine.new(4.3)
        int2 = Primatives::IntegerMine.new(2)
        expression = Relational::LessThan.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = false
        assert_equal expected, actual.value
    end

    def test_greaterThan_float
        int1 = Primatives::FloatMine.new(4.3)
        int2 = Primatives::IntegerMine.new(2)
        expression = Relational::GreaterThan.new(int1, int2)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = true
        assert_equal expected, actual.value

        # bad type

        int1 = Primatives::FloatMine.new(4.3)
        int2 = Primatives::Boolean.new(true)
        assert_raise(RuntimeError) {Relational::GreaterThan.new(int1, int2).traverse(@evaluator, @runtime)}
    end

    def test_casting_to_float
        int1 = Primatives::IntegerMine.new(4)
        expression = Casting::IntToFloatMine.new(int1)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 4.0
        assert_equal expected, actual.value
    end

    def test_casting_to_int
        int1 = Primatives::FloatMine.new(4.3)
        expression = Casting::FloatToIntMine.new(int1)
        actual = expression.traverse(@evaluator, @runtime) 
        expected = 4
        assert_equal expected, actual.value
    end
  end
end
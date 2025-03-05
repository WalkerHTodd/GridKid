require_relative 'Lexer.rb'
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
require_relative 'Conditionals.rb'

include Primatives
include Arithmetic
include Logical
include Cell
include Relational
include Bitwise
include Statistical
include Casting
include Conditionals

class Parser
  
  def initialize(tokens, runtime)
    @tokens = tokens  
    @current_token_index = 0
    @runtime = runtime
  end
  
  def has(token_type)
    @current_token_index < @tokens.length && @tokens[@current_token_index].type == token_type
  end

  def advance()
    @current_token_index += 1
  end

  def consume(token_type)
    if has(token_type)
      token = @tokens[@current_token_index]
      advance()
      return token
    end
  end

  # testing helper method to see if we have a charecter ahead
  def check_ahead(token_type)
    for i in (@current_token_index + 1)...@tokens.length
      if @tokens[i].type == token_type
        return true
      end
    end
    return false
  end

  def parse()
    return conditional_expression()
  end

  def block_expression()
    statements = []
    while !has(:end)
      statements.push(expression())
    end
    return Block.new(statements)
  end

  def conditional_expression()
    left = expression()
    if has(:if)
      consume(:if)
      consume(:left_parenthesis)
      condition = expression()
      consume(:right_parenthesis)
      if_true = block_expression()
      if_false = nil
      if has(:else)
        consume(:else)
        if_false = block_expression()
      end
      consume(:end)
      return IfStatement.new(condition, if_true, if_false)
    elsif has(:for)
      consume(:for)
      variable = consume(:string)
      consume(:in)
      start = expression()
      consume(:dot)
      consume(:dot)
      ending = expression()
      consume(:do)
      body = block_expression()
      consume(:end)
      return ForLoop.new(variable, start, ending, body)
    elsif has(:variable_assignment)
      consume(:variable_assignment)
      right = expression()
      variable = VariableAssignment.new(StringMine.new(left), IntegerMine.new(right))
      variable.set_variable(@runtime)
      return variable
    else
      return left
    end
  end

  
  def expression()
    if has(:equals)
      consume(:equals)
    end
    return additive_expression()
  end

  def additive_expression()
    left = multiplicative_expression()
    while has(:plus) || has(:minus)
      token = consume(:plus) || consume(:minus)
      right = multiplicative_expression()
      if token.type == :plus
        left = Addition.new(left, right)
      elsif token.type == :minus
        left = Subtraction.new(left, right)
      end
    end
    return left
  end

  def multiplicative_expression()
    left = logical_expressions()
    while has(:multiplication) || has(:division) || has(:modulus) || has(:exponent)
      token = consume(:multiplication) || consume(:division) || consume(:modulus) || consume(:exponent)
      right = bitwise_expressions()
      if token.type == :multiplication
        left = Multiplication.new(left, right)
      elsif token.type == :division
        left = Division.new(left, right)
      elsif token.type == :exponent
        left = Exponentiation.new(left, right)
      else
        left = Modulus.new(left, right)
      end
    end
    return left
  end

  def logical_expressions()
    left = bitwise_expressions()
    while has(:and) || has(:or) || has(:not)
      token = consume(:and) || consume(:or) || consume(:not)
      right = bitwise_expressions()
      if token.type == :and
        left = And.new(left, right)
      elsif token.type == :or
        left = Or.new(left, right)
      else
        left = Not.new(right)
      end
    end
    return left
  end

  # Bitwise Operations
  def bitwise_expressions()
    left = relational_expression()
    while has(:bitwise_and) || has(:bitwise_or) || has(:bitwise_xor) || has(:bitwise_not) || has(:left_shift) || has(:right_shift)
      token = consume(:bitwise_and) || consume(:bitwise_or) || consume(:bitwise_xor) || consume(:bitwise_not) || consume(:left_shift) || consume(:right_shift)
      right = relational_expression()
      if token.type == :bitwise_and
        left = BitwiseAnd.new(left, right)
      elsif token.type == :bitwise_or
        left = BitwiseOr.new(left, right)
      elsif token.type == :bitwise_xor
        left = Xor.new(left, right)
      elsif token.type == :bitwise_not
        left = BitwiseNot.new(right)
      elsif token.type == :left_shift
        left = LeftShift.new(left, right)
      elsif token.type == :right_shift
        left = RightShift.new(left, right)
      end
    end
    return left
  end

  def relational_expression()
    left = primary_expression()
    if has(:less_than) || has(:greater_than) || has(:less_than_or_equal) || has(:greater_than_or_equal) || has(:equal) || has(:not_equal)
      token = consume(:less_than) || consume(:greater_than) || consume(:less_than_or_equal) || consume(:greater_than_or_equal) || consume(:equal) || consume(:not_equal)
      right = primary_expression()
      if token.type == :less_than
        return LessThan.new(left, right)
      elsif token.type == :greater_than
        return GreaterThan.new(left, right)
      elsif token.type == :less_than_or_equal
        return LessThanOrEqual.new(left, right)
      elsif token.type == :greater_than_or_equal
        return GreaterThanOrEqual.new(left, right)
      elsif token.type == :equal
        return Equals.new(left, right)
      elsif token.type == :not_equal
        return NotEquals.new(left, right)
      end
    else
      return left
    end
  end

 
  def primary_expression()
    if has(:left_parenthesis)
      consume(:left_parenthesis)
      expression = expression()
      consume(:right_parenthesis)
      return expression
    else
      return cells()
    end
  end



  def cells()
    if has(:r_value)
      consume(:r_value)

      consume(:left_bracket)
      left = expression()
      consume(:comma)
      right = expression()
      consume(:right_bracket)
      return RightValueCell.new(left, right)

    # checking for a normal cell
    elsif has(:left_bracket)
      consume(:left_bracket)
      if !check_ahead(:comma) || !check_ahead(:right_bracket)
        raise "Invalid cell address format at line #{@tokens[@current_token_index - 1]}"
      end
      left = expression()
      consume(:comma)
      right = expression()
      consume(:right_bracket)
      return CellAddress.new(left, right)
    else 
      return primatives()
    end
  end

  def primatives()
    if has(:integer_literal)
      token = @tokens[@current_token_index]
      advance()
      return IntegerMine.new(token.value.to_i)
    elsif has(:float_literal)
      token = @tokens[@current_token_index]
      advance()
      return FloatMine.new(token.value.to_f)
    elsif has(:boolean_literal)
      token = @tokens[@current_token_index]
      advance()
      return Boolean.new(token.value)
    elsif has(:string)
      token = @tokens[@current_token_index]
      advance()
      return StringMine.new(token.value)
    elsif has(:float_cast)
      consume(:float_cast)
      consume(:left_parenthesis)
      expression = expression()
      consume(:right_parenthesis)
      return FloatMine.new(expression)
    elsif has(:integer_cast)
      token = @tokens[@current_token_index]
      advance()
      consume(:left_parenthesis)
      expression = expression()
      consume(:right_parenthesis)
      return IntegerMine.new(expression)
    elsif has(:Sum)
      consume(:Sum)
      consume(:left_parenthesis)
      left = expression()
      consume(:comma)
      right = expression()
      consume(:right_parenthesis)
      return Statistical::Sum.new(left, right)
    elsif has(:Max)
      consume(:Max)
      consume(:left_parenthesis)
      left = expression()
      consume(:comma)
      right = expression()
      consume(:right_parenthesis)
      return Statistical::Max.new(left, right)
    elsif has(:Min)
      consume(:Min)
      consume(:left_parenthesis)
      left = expression()
      consume(:comma)
      right = expression()
      consume(:right_parenthesis)
      return Statistical::Min.new(left, right)
    elsif has(:Mean)
      consume(:Mean)
      consume(:left_parenthesis)
      left = expression()
      consume(:comma)
      right = expression()
      consume(:right_parenthesis)
      return Statistical::Mean.new(left, right)
    end
  end
end

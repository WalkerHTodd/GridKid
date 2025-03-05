require_relative 'Token.rb'

class Lexer
  attr_reader :tokens, :string, :index, :string_tokens

  def initialize(string)
    @string = string
    @tokens = []
    @index = 0
    @string_tokens = []  
  end

  def capture()
    @string_tokens << @string[@index] 
    @index += 1
  end
  
  def capture_number()
    if !has_number()
      raise "Invalid number after decimal: #{@string[@index]}"
    end

    while has_number()
      capture()
    end
  end

  def has_number()
    has("0") || has("1") || has("2") || has("3") || has("4") || has("5") || has("6") || has("7") || has("8") || has("9")
    # The regex wont work for me for some reason when I try to do it
    # @string[@index].match?(/[0-9]/)
  end

  def emit_token(token_type)
    start_index = @index - @string_tokens.length
    token_text = @string_tokens.join
    token = Token.new(token_type, token_text, start_index, @index)
    @tokens << token
    @string_tokens = []
  end
  
  def lex
    while @index < @string.length
      if has("+")
        capture()
        emit_token(:plus)
      elsif has("-")
        capture()
        emit_token(:minus)
      elsif has(";")
        capture()
        emit_token(:semicolon)
      elsif has("*")
        capture()
        if has("*")
          capture()
          emit_token(:exponent)
        else
          emit_token(:multiplication)
        end
      elsif has("/")
        capture()
        emit_token(:division)
      elsif has("%")
        capture()
        emit_token(:modulus)
      elsif has("^")
        capture()
        emit_token(:xor)
      elsif has("(")
        capture()
        emit_token(:left_parenthesis)
      elsif has(")")
        capture()
        emit_token(:right_parenthesis)
      elsif has("#")
        capture()
        emit_token(:r_value)
      # Cell Checker
      elsif has("[")
        capture()
        emit_token(:left_bracket)
      elsif has("]")
        capture()
        emit_token(:right_bracket)
      elsif has("{")
        capture()
        emit_token(:left_brace)
      elsif has("}")
        capture()
        emit_token(:right_brace)
      elsif has(",")
        capture()
        emit_token(:comma)
      elsif has("~")
        capture()
        emit_token(:bitwise_not)
      elsif has_number()
        capture_number()
        if has(".")
          capture()
          capture_number()
          emit_token(:float_literal)
        else
          emit_token(:integer_literal)
        end
      elsif has("<")
        capture()
        if has("=")
          capture()
          emit_token(:less_than_or_equal)
        elsif has("<")
          capture()
          emit_token(:left_shift)
        else
          emit_token(:less_than)
        end
      elsif has(".")
        capture()
        emit_token(:dot)
      elsif has(">")
        capture()
        if has("=")
          capture()
          emit_token(:greater_than_or_equal)
        elsif has(">")
          capture()
          emit_token(:right_shift)
        else
          emit_token(:greater_than)
        end
      elsif has("=")
        capture()
        emit_token(:equals)
        if has("=")
          capture()
          emit_token(:equal)
        end
      elsif has("!")
        capture()
        if has("=")
          capture()
          emit_token(:not_equal)
        else
          emit_token(:not)
        end
      elsif has("&")
        capture()
        if has("&")
          capture()
          emit_token(:logical_and)
        else
          emit_token(:bitwise_and)
        end
      elsif has("|")
        capture()
        if has("|")
          capture()
          emit_token(:logical_or)
        else
          emit_token(:bitwise_or)
        end
      elsif has_letter()
        while has_letter()
          capture()
        end

        # check if the next token no matter spaces in between is an = then we know its a variable assignment
        # it is getting to here and getting a variable assignment token

        case @string_tokens.join
        when "max"
          emit_token(:Max)
        when "min"
          emit_token(:Min)
        when "sum"
          emit_token(:Sum)
        when "mean"
          emit_token(:Mean)
        when "int"
          emit_token(:int_cast)
        when "float"
          emit_token(:float_cast)
        when "true"
          emit_token(:boolean_literal)
        when "false"
          emit_token(:boolean_literal)
        when "if"
          emit_token(:if)
        when "else"
          emit_token(:else)
        when "for"
          emit_token(:for)
        when "end"
          emit_token(:end)
        when "in"
          emit_token(:in)
        else
          if has(" ")
            while has(" ")
              @index += 1
            end
          end
          if has("=")
            capture()
            emit_token(:variable_assignment)
          else
            emit_token(:string)
          end
        end
        
      elsif has(" ")
        @index += 1
      else
        raise "Unknown token: #{@string[@index]}"
      end
    end
    @tokens
  end

  def has(token_type)
    @index < @string.length && @string[@index] == token_type
  end

  def has_letter()
    @index < @string.length && @string[@index].match?(/[a-zA-Z]/)
  end
end

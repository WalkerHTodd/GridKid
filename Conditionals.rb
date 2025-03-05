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

include Primatives
include Arithmetic
include Logical
include Cell
include Relational
include Bitwise
include Statistical
include Casting

module Conditionals
    class IfStatement
        attr_reader :condition, :if_true, :if_false
        def initialize(condition, if_true, if_false)
            @condition = condition
            @if_true = if_true
            @if_false = if_false
        end

        def traverse(visitor, runtime)
            visitor.visit_conditionals(self, runtime)
        end
    end

    class Block
        attr_reader :statements
        def initialize(statements)
            @statements = statements
        end

        def traverse(visitor, runtime)
            visitor.visit_block(self, runtime)
        end
    end
    
    class VariableAssignment
        attr_reader :variable, :value
        def initialize(variable, value)
            @variable = variable
            @value = value
        end

        def set_variable(runtime)
            runtime.set_variable(@variable.value, @value)
        end

        def traverse(visitor, runtime)
            visitor.visit_variableAssignment(self, runtime)
        end
    end

    class ForLoop
        attr_reader :variable, :start, :ending, :body
        def initialize(variable, start, ending, body)
            @variable = variable
            @start = start
            @ending = ending
            @body = body
        end

        def traverse(visitor, runtime)
            visitor.visit_for_loop(self, runtime)
        end
    end
end
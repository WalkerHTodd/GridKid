    require_relative 'Primatives.rb'

    class Serializer

    def visit_conditionals(node, runtime)
        condition = node.condition.traverse(self, runtime)
        if_true = node.if_true.traverse(self, runtime)
        if_false = node.if_false.traverse(self, runtime)
        "if (#{condition}) { #{if_true} } else { #{if_false} }"
    end

    def visit_variableAssignment(node, runtime)
        variable = node.variable.traverse(self, runtime)
        value = node.value.traverse(self, runtime)
        runtime.set_variable(variable, value)
        "#{variable} = #{value}"
    end

    def visit_for_loop(node, runtime)
        variable = node.variable.traverse(self, runtime)
        start = node.start.traverse(self, runtime)
        end_ = node.end.traverse(self, runtime)
        body = node.body.traverse(self, runtime)
        "for (int #{variable} = #{start}; #{variable} < #{end_}; #{variable}++) { #{body} }"
    end

    """
    Primitive Operations
    """

    def visit_integer(node, runtime)
        node.value.to_s
    end

    def visit_float(node, runtime)
        node.value.to_s
    end

    def visit_boolean(node, runtime)
        node.value.to_s
    end

    def visit_string(node, runtime)
        node.value
    end

    def visit_cell(node, runtime)
        "[#{node.row.to_s}, #{node.column.to_s}]"
    end

    """
    Cell Operations
    """

    def visit_leftValueCell(node, runtime)
        row = node.row.traverse(self, runtime)
        col = node.column.traverse(self, runtime)
        
        "[ones#{row}, tens#{col}]"

    end

    def visit_rightValueCell(node, runtime)
        row = node.row.traverse(self, runtime)
        col = node.column.traverse(self, runtime)
        
        "#[#{row}, #{col}]"
    end

    """
    Arithmetic Operations
    """

    def visit_add(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} + #{right})"
    end

    def visit_subtract(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} - #{right})"
    end

    def visit_multiplication(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "#{left} * #{right}"
    end

    def visit_division(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} / #{right})"
    end

    def visit_exponentiation(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} ** #{right})"
    end

    def visit_modulus(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "#{left} % #{right}"
    end

    def visit_negation(node, runtime)
        value = node.value.traverse(self, runtime)
        "-(#{value})"
    end

    """
    Relational Operations
    """

    def visit_lessThan(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} < #{right})"

    end

    def visit_greaterThan(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} > #{right})"
    end

    def visit_lessThanEqualTo(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} <= #{right})"
    end

    def visit_greaterThanEqualTo(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} >= #{right})"
    end

    def visit_equals(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} = #{right})"
    end

    def visit_notEquals(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} != #{right})"
    end

    def visit_and(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} && #{right})"
    end

    def visit_or(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} || #{right})"
    end

    def visit_not(node, runtime)
        value = node.value.traverse(self, runtime)
        "!(#{value})"
    end


    """
    Statistical Operations
    """
    
    def visit_sum(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        
        "sum(#{left}, #{right})"
    end

    def visit_max(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        
        "max(#{left}, #{right})"
    end

    def visit_min(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        
        "min(#{left}, #{right})"
    end

    def visit_mean(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        
        "mean(#{left}, #{right})"
    end

    """
    Bitwise Operations
    """

    def visit_bitwise_and(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} & #{right})"    

    end

    def visit_bitwise_or(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} | #{right})"    
    end

    def visit_bitwise_not(node, runtime)
        value = node.value.traverse(self, runtime)
        "~(#{value})"    
    end

    def visit_bitwise_xor(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "(#{left} ^ #{right})"    
    end

    def visit_bitwise_left_shift(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "#{left} << #{right}"    
    end

    def visit_bitwise_right_shift(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        "#{left} >> #{right}"    
    end

    """
    Cast Operations
    """

    def visit_floatToInt(node, runtime)
        value = node.value.traverse(self, runtime)
        "int(#{value})"    

    end

    def visit_intToFloat(node, runtime)
        value = node.value.traverse(self, runtime)
        "float(#{value})"    
    end

end
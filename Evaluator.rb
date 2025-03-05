require_relative 'Primatives.rb'

class Evaluator
    
    def visit_block (node, runtime)
        node.statements.each do |statement|
            statement.traverse(self, runtime)
        end
    end

    def visit_variableAssignment(node, runtime)
        variable = node.variable
        value = node.value.traverse(self, runtime)
        runtime.set_variable(variable, value)
        value.value
    end

    def visit_conditionals(node, runtime)
        condition = node.condition.traverse(self, runtime)
        if_true = node.if_true.traverse(self, runtime)
        if node.if_false != nil
            if_false = node.if_false.traverse(self, runtime)
        else 
            condition.value ? if_true : nil
        end
        condition.value ? if_true : if_false
    end

    def visit_for_loop(node, runtime)
        variable = node.variable
        start = node.start.traverse(self, runtime).value
        end_value = node.ending.traverse(self, runtime).value
        body = node.body

        (start..end_value).each do |i|
            runtime.set_variable(variable, Primatives::IntegerMine.new(i))
            body.traverse(self, runtime)
        end
    end

    """
    Primative Operations
    """

    def visit_integer(node, runtime)
       node
    end

    def visit_float(node, runtime)
        node
    end

    def visit_boolean(node, runtime)
        node
    end

    def visit_string(node, runtime)
        node
    end

    def visit_cell(node, runtime)
        node
    end

    """
    Arithmetic Operations
    """

    def visit_subtract(node, runtime)
        begin
            left_value = node.left.traverse(self, runtime)
        rescue => exception
            left_value = Primatives::IntegerMine.new(0)
        end

        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::FloatMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "Addition operation not supported for #{left_value.class} and #{right_value.class}"
        end

        if left_value.is_a?(Primatives::FloatMine) || right_value.is_a?(Primatives::FloatMine)
            Primatives::FloatMine.new(left_value.value - right_value.value)
        else
            Primatives::IntegerMine.new((left_value.value - right_value.value))
        end
    end

    def visit_multiplication(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if runtime.variables[left_value] != nil
            left_value = runtime.get_variable(left_value.value)
        end
        if runtime.variables[right_value] != nil
            right_value = runtime.get_variable(right_value.value)
        end

        Primatives::FloatMine.new(left_value.value.to_f * right_value.value.to_f)
    end

    def visit_add(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::FloatMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "Addition operation not supported for #{left_value.class} and #{right_value.class}"
        end

        if left_value.is_a?(Primatives::FloatMine) || right_value.is_a?(Primatives::FloatMine)
            Primatives::FloatMine.new(left_value.value.to_f + right_value.value)
        else
            Primatives::IntegerMine.new((left_value.value + right_value.value))
        end
    end

    def visit_division(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::FloatMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "Division operation not supported for #{left_value.class}"
        end
        if !right_value.is_a?(Primatives::FloatMine) & !right_value.is_a?(Primatives::IntegerMine)
            raise "Division operation not supported for #{right_value.class}"
        end

        if left_value.is_a?(Primatives::FloatMine) 
            Primatives::FloatMine.new((left_value.value.value / right_value.value).round(3))
        elsif right_value.is_a?(Primatives::FloatMine)
            Primatives::FloatMine.new((left_value.value / right_value.value.value).round(3))
        else
            Primatives::IntegerMine.new((left_value.value / right_value.value))
        end
    end

    def visit_exponentiation(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::FloatMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "Addition operation not supported for #{left_value.class} and #{right_value.class}"
        end

        if left_value.is_a?(Primatives::FloatMine) || right_value.is_a?(Primatives::FloatMine)
            Primatives::FloatMine.new((left_value.value.to_f ** right_value.value).round(3))
        else
            Primatives::IntegerMine.new((left_value.value ** right_value.value))
        end
    end

    def visit_negation(node, runtime)
        left_value = node.value.traverse(self, runtime)
        if !left_value.is_a?(Primatives::FloatMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "negation operation not supported for #{left_value.class} and #{right_value.class}"
        end

        if left_value.is_a?(Primatives::FloatMine)
            Primatives::FloatMine.new((left_value.value * -1))
        else
            Primatives::IntegerMine.new((left_value.value * -1))
        end
    end

    def visit_modulus(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::FloatMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "Addition operation not supported for #{left_value.class} and #{right_value.class}"
        end

        if left_value.is_a?(Primatives::FloatMine) || right_value.is_a?(Primatives::FloatMine)
            Primatives::FloatMine.new((left_value.value % right_value.value).round(3))
        else
            Primatives::IntegerMine.new((left_value.value % right_value.value))
        end
    end

    """
    Statistical Operations
    """

    def visit_max(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        max = -Float::INFINITY
        float_in_cell = false
        for i in left.column.value..right.column.value   
            for j in left.row.value..right.row.value  
                new_cell = runtime.grid.get_cell(Primatives::CellAddress.new(j, i))
                if new_cell.is_a?(Primatives::FloatMine)
                    float_in_cell = true
                end 
                if new_cell.to_f > max
                    max = new_cell.to_f
                end
                
            end
        end
        if float_in_cell
            Primatives::FloatMine.new(max)
        else
            Primatives::IntegerMine.new(max)
        end
    end

    def visit_min(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        min = Float::INFINITY
        float_in_cell = false
        for i in left.column.value..right.column.value   
            for j in left.row.value..right.row.value  
                new_cell = runtime.grid.get_cell(Primatives::CellAddress.new(j, i))
                if new_cell.is_a?(Primatives::FloatMine)
                    float_in_cell = true
                end 
                    if new_cell.to_f < min
                        min = new_cell.to_f
                    end
                
            end
        end
        if float_in_cell
            Primatives::FloatMine.new(min)
        else
            Primatives::IntegerMine.new(min)
        end
    end

    def visit_mean(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        sum = 0
        mean = 0
        count = 0

        for i in left.column.value..right.column.value   
            for j in left.row.value..right.row.value     
                new_cell = runtime.grid.get_cell(Primatives::CellAddress.new(j, i))
                sum += new_cell.to_i
                count += 1
            end
        end
        mean = (sum.to_f / count)
        Primatives::FloatMine.new(mean)
    end

    def visit_sum(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        sum = 0
        float_in_cell = false

        for i in left.column.value..right.column.value   
            for j in left.row.value..right.row.value   
                new_cell = runtime.grid.get_cell(Primatives::CellAddress.new(j, i))
                if new_cell.is_a?(Primatives::FloatMine)
                    float_in_cell = true
                end
                sum += new_cell.to_i
            end
        end
        if float_in_cell
            Primatives::FloatMine.new(sum)
        else
            Primatives::IntegerMine.new(sum)
        end
    end

    
    """
    Bitwise Operations
    """

    def visit_bitwise_and(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::IntegerMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "BitwiseAnd operation not supported for #{left_value.class} and #{right_value.class}"
        end
        
        Primatives::IntegerMine.new(left_value.value & right_value.value)
    end

    def visit_bitwise_or(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::IntegerMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "BitwiseAnd operation not supported for #{left_value.class} and #{right_value.class}"
        end
        
        Primatives::IntegerMine.new(left_value.value | right_value.value)
    end

    def visit_bitwise_not(node, runtime)
        value = node.value.traverse(self, runtime)
        if !value.is_a?(Primatives::IntegerMine)
            raise "Bitwise NOT operation not supported for #{value.class}"
        end
        Primatives::IntegerMine.new(~value.value)

    end

    def visit_bitwise_xor(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::IntegerMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "BitwiseAnd operation not supported for #{left_value.class} and #{right_value.class}"
        end
        
        Primatives::IntegerMine.new(left_value.value ^ right_value.value)
    end

    def visit_bitwise_left_shift(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        
        if !left_value.is_a?(Primatives::IntegerMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "BitwiseLeftShift operation not supported for #{left_value.class} and #{right_value.class}"
        end
        
        Primatives::IntegerMine.new(left_value << right_value)
    end

    def visit_bitwise_right_shift(node, runtime)
        left_value = node.left.traverse(self, runtime)
        right_value = node.right.traverse(self, runtime)
        if !left_value.is_a?(Primatives::IntegerMine) & !left_value.is_a?(Primatives::IntegerMine)
            raise "BitwiseRightShift operation not supported for #{left_value.class} and #{right_value.class}"
        end
        
        Primatives::IntegerMine.new(left_value.value >> right_value.value)
    end

    """
    Logical Operations
    """

    def visit_and(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        if !left.is_a?(Primatives::Boolean) || !right.is_a?(Primatives::Boolean)
            raise "And operation not supported for #{left.class} and #{right.class}"
        end
        Primatives::Boolean.new(left.value && right.value)
    end

    def visit_or(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        if !left.is_a?(Primatives::Boolean) || !right.is_a?(Primatives::Boolean)
            raise "Or operation not supported for #{left.class} and #{right.class}"
        end
        Primatives::Boolean.new(left.value || right.value)
    end

    def visit_not(node, runtime)
        value = node.value.traverse(self, runtime)
        if !value.is_a?(Primatives::Boolean)
            raise "Not operation not supported for #{value.class}"
        end
        Primatives::Boolean.new(!value)
    end


    """
    Cast Operations
    """

    def visit_floatToInt(node, runtime)
        value = node.value.traverse(self, runtime)
        if !value.is_a?(Primatives::FloatMine)
            raise "FloatToInt operation not supported for #{value.class}"
        end
        Primatives::IntegerMine.new(value.value.to_i)
    end

    def visit_intToFloat(node, runtime)
        value = node.value.traverse(self, runtime)
        if !value.is_a?(Primatives::IntegerMine)
            raise "IntToFloat operation not supported for #{value.class}"
        end
        Primatives::FloatMine.new(value.to_f)
    end

    """
    Cell Operations
    """

    def visit_leftValueCell(node, runtime)
        row = node.row.traverse(self, runtime)
        column = node.column.traverse(self, runtime)
        if !row.is_a?(Primatives::IntegerMine) || !column.is_a?(Primatives::IntegerMine)
            raise "Cell address must be an integer"
        end
        
        Primatives::CellAddress.new(row.value, column.value)

    end

    def visit_rightValueCell(node, runtime)
        row = node.row.traverse(self, runtime)
        column = node.column.traverse(self, runtime)
        if !row.is_a?(Primatives::IntegerMine) || !column.is_a?(Primatives::IntegerMine)
            raise "Cell address must be an integer"
        end

        runtime.grid.get_cell(Primatives::CellAddress.new(row.value, column.value))
    end

    """
    Relational Operations
    """

    def visit_lessThan(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        if !left.is_a?(Primatives::FloatMine) & !left.is_a?(Primatives::IntegerMine)
            raise "LessThan operation not supported for #{left.class} and #{right.class}"
        end
        if !right.is_a?(Primatives::FloatMine) & !right.is_a?(Primatives::IntegerMine)
            raise "LessThan operation not supported for #{left.class} and #{right.class}"
        end
        Primatives::Boolean.new(left.value < right.value)
    end

    def visit_greaterThan(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)
        if !left.is_a?(Primatives::FloatMine) & !left.is_a?(Primatives::IntegerMine)
            raise "greaterThan operation not supported for #{left.class} and #{right.class}"
        end
        if !right.is_a?(Primatives::FloatMine) & !right.is_a?(Primatives::IntegerMine)
            raise "greaterThan operation not supported for #{left.class} and #{right.class}"
        end

        Primatives::Boolean.new(left.value > right.value)
    end

    def visit_lessThanEqualTo(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)

        if !left.is_a?(Primatives::FloatMine) & !left.is_a?(Primatives::IntegerMine)
            raise "lessThanEqualto operation not supported for #{left.class} and #{right.class}"
        end
        if !right.is_a?(Primatives::FloatMine) & !right.is_a?(Primatives::IntegerMine)
            raise "lessThanEqualto operation not supported for #{left.class} and #{right.class}"
        end

        Primatives::Boolean.new(left.value <= right.value)
    end

    def visit_greaterThanEqualTo(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)

        if !left.is_a?(Primatives::FloatMine) & !left.is_a?(Primatives::IntegerMine)
            raise "greaterThan operation not supported for #{left.class} and #{right.class}"
        end
        if !right.is_a?(Primatives::FloatMine) & !right.is_a?(Primatives::IntegerMine)
            raise "greaterThan operation not supported for #{left.class} and #{right.class}"
        end

        Primatives::Boolean.new(left.value >= right.value)
    end

    def visit_equals(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)

        if !left.is_a?(Primatives::FloatMine) & !left.is_a?(Primatives::IntegerMine)
            raise "equals operation not supported for #{left.class} and #{right.class}"
        end
        if !right.is_a?(Primatives::FloatMine) & !right.is_a?(Primatives::IntegerMine)
            raise "equals operation not supported for #{left.class} and #{right.class}"
        end

        Primatives::Boolean.new(left.value == right.value)
    end

    def visit_notEquals(node, runtime)
        left = node.left.traverse(self, runtime)
        right = node.right.traverse(self, runtime)

        if !left.is_a?(Primatives::FloatMine) & !left.is_a?(Primatives::IntegerMine)
            raise "notEquals operation not supported for #{left.class} and #{right.class}"
        end
        if !right.is_a?(Primatives::FloatMine) & !right.is_a?(Primatives::IntegerMine)
            raise "notEquals operation not supported for #{left.class} and #{right.class}"
        end

        Primatives::Boolean.new(left.value != right.value)
    
    end

end




module Primatives
    class IntegerMine
        attr_reader :value
        def initialize(value)
            @value = value
        end

        def traverse(visitor, runtime)
            visitor.visit_integer(self, runtime)
        end
    end

    class FloatMine
        attr_reader :value
        def initialize(value)
            @value = value
        end

        def traverse(visitor, runtime)
            visitor.visit_float(self, runtime)
        end
    end
    
    class Boolean
        attr_reader :value
        def initialize(value)
            @value = value
        end

        def traverse(visitor, runtime)
            visitor.visit_boolean(self, runtime)
        end
    end


    class StringMine
        attr_reader :value
        def initialize(value)
            @value = value
        end

        def traverse(visitor, runtime)
            visitor.visit_string(self, runtime)
        end
    end
    
    class CellAddress
        attr_reader :row 
        attr_reader :column
        def initialize(row, column)
            @row = row
            @column = column
        end

        def traverse(visitor, runtime)
            visitor.visit_cell(self, runtime)
        end
    end
end

module Casting
    class FloatToIntMine
        attr_reader :value
        def initialize(value)
            @value = value
        end

        def traverse(visitor, runtime)
            visitor.visit_floatToInt(self, runtime)
        end
    end

    class IntToFloatMine
        attr_reader :value
        def initialize(value)
            @value = value
        end

        def traverse(visitor, runtime)
            visitor.visit_intToFloat(self, runtime)
        end
    end
end

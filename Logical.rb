module Logical
    class And
        attr_reader :left
        attr_reader :right

        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_and(self, runtime)
        end
    end

    class Or
        attr_reader :left
        attr_reader :right

        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_or(self, runtime)
        end
    end

    class Not
        attr_reader :value

        def initialize(value)
            @value = value
        end

        def traverse(visitor, runtime)
            visitor.visit_not(self, runtime)
        end
    end
end

    
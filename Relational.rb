
module Relational
    class LessThan
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end
        def traverse(visitor, runtime)
            visitor.visit_lessThan(self, runtime)
        end
    end

    class GreaterThan
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_greaterThan(self, runtime)
        end
    end

    class LessThanEqualTo
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_lessThanEqualTo(self, runtime)
        end
    end

    class GreaterThanEqualTo
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_greaterThanEqualTo(self, runtime)
        end
    end

    class Equals
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_equals(self, runtime)
        end
    end

    class NotEquals
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_notEquals(self, runtime)
        end
    end
end
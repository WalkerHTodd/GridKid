module Statistical
    class Max
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_max(self, runtime)
        end
    end

    class Min
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end
        def traverse(visitor, runtime)
            visitor.visit_min(self, runtime)
        end
    end

    class Mean
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_mean(self, runtime)
        end
    end

    class Sum
        attr_reader :left
        attr_reader :right
        def initialize(left, right)
            @left = left
            @right = right
        end

        def traverse(visitor, runtime)
            visitor.visit_sum(self, runtime)
        end
    end
end
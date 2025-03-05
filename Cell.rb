require_relative 'Primatives.rb'
module Cell
    # the location of the cell
    class LeftValueCell
        attr_reader :row
        attr_reader :column

        def initialize(row, column)
            @row = row
            @column = column
        end

        def traverse(visitor, runtime)
            visitor.visit_leftValueCell(self, runtime)
        end
    end

    # value inside hte cell
    class RightValueCell
        attr_reader :row
        attr_reader :column

        def initialize(row, column)
            @row = row
            @column = column
        end

        def traverse(visitor, runtime)
            visitor.visit_rightValueCell(self, runtime)
        end
    end

    class Grid
        attr_reader :rows
        attr_reader :columns
        attr_reader :cells
        def initialize(rows, columns)
            @rows = rows
            @columns = columns
            @cells = Array.new(rows) {Array.new(columns)}
        end

        def set_cell(address, value)
            @cells[address.row][address.column] = value
        end

        def get_cell(address)
            @cells[address.row][address.column]
        end
    end

    class Runtime 
        attr_reader :grid
        attr_reader :variables
        def initialize(rows, columns)
            @grid = Grid.new(rows, columns)
            @variables = {}
        end

        def set_variable(name, value)
            @variables[name] = value
        end

        def get_variable(name)
            @variables[name]
        end
    end
end
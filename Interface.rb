require 'curses'
require_relative 'Cell.rb'
require_relative 'Lexer.rb'
require_relative 'Parser.rb'
require_relative 'Evaluator.rb'
require_relative 'Serializer.rb'
require_relative 'Cell.rb'
require_relative 'Primatives.rb'

class Spreadsheet
  def initialize
    @selected_cell = [0, 0]  # Start at the first cell in the grid
    @evaluated_list = []
    @amount_text_entered = 0
    @runtime = Runtime.new(50, 50)
    @serializer = Serializer.new
    # Initialize the main window
    @main_window = Curses::Window.new(Curses.lines, Curses.cols, 0, 0)
    @main_window.keypad = true
    @enter_inside = false
    @newline = false
    @formula_editor_cursor_y = 1
    @formula_editor_cursor_x = 20
    # Calculate the dimensions and positions of sub-panels
    calculate_panel_dimensions
  
    # Initialize sub-panels
    initialize_formula_editor
    initialize_display_panel
    initialize_grid
  
    draw_interface
  end
  
  
  def calculate_panel_dimensions
    @grid_height = Curses.lines - 8
    @grid_width = Curses.cols - 2
    @grid_y = 1
    @grid_x = 1
  
    # Calculate dimensions and positions for the formula editor
    @formula_editor_height = 6
    @formula_editor_width = Curses.cols - 2
    @formula_editor_y = Curses.lines - 10
    @formula_editor_x = 1
  
    # Calculate dimensions and positions for the display panel
    @display_panel_height = 3
    @display_panel_width = Curses.cols - 2
    @display_panel_y = Curses.lines - 3
    @display_panel_x = 1
  end
  
  def run
    loop do
      handle_input
    end
  ensure
    Curses.close_screen
  end
 
  def initialize_formula_editor
    @formula_editor = @main_window.subwin(@formula_editor_height, @formula_editor_width, @formula_editor_y, @formula_editor_x)
    @formula_editor.box('|', '-')
    @formula_editor.setpos(1, 1)
    @formula_editor.addstr('Formula Editor   | Press Enter to edit cell contents        ')
  end
  
  def initialize_display_panel
    @display_panel = @main_window.subwin(@display_panel_height, @display_panel_width, @display_panel_y, @display_panel_x)
    @display_panel.box('|', '-')
    @display_panel.setpos(1, 1)
    @display_panel.addstr('Display Panel    |')
  end
  
  
  def initialize_grid
    terminal_height = Curses.lines
    terminal_width = Curses.cols
    max_rows = (terminal_height - 12) / 2 
    max_columns = (terminal_width - 2) / 8  

    # Use the calculated maximum rows and columns or default to 10 if the terminal is too small
    @rows = max_rows > 0 ? max_rows : 10
    @columns = max_columns > 0 ? max_columns : 10
    
    y = 1
    x = 1
    height = @rows * 2  # Each row occupies 2 lines (cell + border)
    width = @columns * 8  # Each column occupies 8 characters (cell + border)
    
    @grid_window = @main_window.subwin(height, width, y, x)
    @grid_window.box('|', '-')
    @grid_window.keypad = true  
  end
  
  
  def draw_interface
    draw_display_panel
    draw_formula_editor
    draw_grid
    @formula_editor.refresh
    @display_panel.refresh
    @grid_window.refresh
  end

  def draw_formula_editor
    @formula_editor.setpos(1, 1)
    @formula_editor.refresh
  end

  def draw_display_panel
    @display_panel.setpos(1, 1)
    @display_panel.refresh
  end

  def draw_grid
    # Draw horizontal lines
    (@rows + 1).times do |row|
      @grid_window.setpos(row * 2, 0)
      @grid_window.addstr("+\u2500\u2500\u2500\u2500\u2500\u2500\u2500") 
      (@columns - 1).times do
        @grid_window.addstr("\u2502\u2500\u2500\u2500\u2500\u2500\u2500\u2500") 
      end
    end
  
    # Draw vertical lines
    (@columns + 1).times do |col|
      @grid_window.setpos(0, col * 8)
      @grid_window.addstr("\u2502")
      @rows.times do |row|
        @grid_window.setpos(row * 2 + 1, col * 8)
        @grid_window.addstr("\u2502       ")  
      end
    end
  
    @rows.times do |row|
      @grid_window.setpos(row * 2 + 1, 0)
      @grid_window.addstr((row).to_s + '   ')  
    end
  
    @columns.times do |col|
      @grid_window.setpos(0, col * 8)
      @grid_window.addstr("\u2500\u2500\u2500#{col}\u2500\u2500\u2500")
    end
    
  
    cursor_row = @selected_cell[0] * 2 + 1
    cursor_col = @selected_cell[1] * 8 + 2
  
    cursor_row = [1, [cursor_row, @rows * 2 - 1].min].max
    cursor_col = [1, [cursor_col, @columns * 8 - 1].min].max
      
      @evaluated_list.each do |evaluated, cell|
      # traverse and get the value for each of the selected tiles
      # and then draw it on the grid
      # need to check for a string
      begin
        lexed = Lexer.new(evaluated).lex
        parsed = Parser.new(lexed, @runtime).parse
        evaluated = parsed.traverse(Evaluator.new, @runtime)
        if evaluated.nil?
          @grid_window.setpos(cell[0] * 2 + 1, cell[1] * 8 + 2)
          @grid_window.addstr('Error')
          if @selected_cell == cell
            @display_panel.setpos(1, 20)
            @display_panel.addstr('Error')
          end
  
        else
          @grid_window.setpos(cell[0] * 2 + 1, cell[1] * 8 + 2)
          begin 
            @grid_window.addstr(evaluated.value.to_s)
            if @selected_cell == cell
              @display_panel.setpos(1, 20)
              @display_panel.addstr(evaluated.value.to_s)
            end
          rescue => e
            # if its equal to a variable in the variable list we want to set it to the value thats associated with ti
            if @runtime.variables[evaluated.to_s] != nil
                @grid_window.addstr(@runtime.variables[evaluated.to_s].value.to_s)
            else
              @grid_window.addstr(evaluated.to_s)
            end
            if @selected_cell == cell
              @display_panel.setpos(1, 20)
              if @runtime.variables[evaluated.to_s] != nil
                @display_panel.addstr(@runtime.variables[evaluated.to_s].value.to_s)
              else
                @display_panel.addstr(evaluated.to_s)
              end
            end
          end
        end
      end
    rescue => e
      @grid_window.setpos(cell[0] * 2 + 1, cell[1] * 8 + 2)
      @grid_window.addstr('Error')
      if @selected_cell == cell
        @display_panel.setpos(1, 20)
        @display_panel.addstr('Error')
      end
    end
    @grid_window.setpos(cursor_row, cursor_col)
    @grid_window.refresh
  end
  
  
  def handle_input
    input = @grid_window.getch
    case input
      when Curses::Key::UP, 65 
        if !@enter_inside
          move_cursor(-1, 0)
        end
      when Curses::Key::DOWN, 66 
        if !@enter_inside
          move_cursor(1, 0)
        end
      when Curses::Key::LEFT, 68 
        if !@enter_inside
          move_cursor(0, -1)
        end
      when Curses::Key::RIGHT, 67 
        if !@enter_inside
          move_cursor(0, 1)
        end
    when "`" # when this key is hit we want to go to the next line of the formula editor panel
      @formula_editor_cursor_y += 1
      @formula_editor_cursor_x = 20
      @formula_editor.setpos(@formula_editor_cursor_y, @formula_editor_cursor_x)
      @formula_editor.refresh

      # the same word is display on the next line after we press enter so we have to someone represent the newline
      @newline = true
    when 10 # Enter key
      handle_enter_key
      @display_panel.refresh
    when Curses::Key::BACKSPACE
      if @enter_inside
        handle_backspace
      end
      draw_grid 
    else
      if @enter_inside
        handle_input_text(input)
      end
      draw_grid 
    end
  end
  
  def handle_backspace
    # need to think about how to handle backspace
    if @amount_text_entered > 0
      @amount_text_entered -= 1
      position = @amount_text_entered + @formula_editor_cursor_x
      @formula_editor.setpos(@formula_editor_cursor_y, position)
      # inserting a space to overwrite the previous character
      @formula_editor.addstr(' ')
      @formula_editor.setpos(@formula_editor_cursor_y, position)
      @runtime.grid.set_cell(Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1]), 
            @runtime.grid.get_cell(Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1]))[0..-2])
      @formula_editor.refresh

      @evaluated_list = @evaluated_list.select do |evaluated, cell|
        cell != @selected_cell
      end

      draw_grid
      @formula_editor.refresh
    end
  end
  
  # Moving the cursor to the formula editor panel when enter is pressed
  # and moving the cursor back to the grid when enter is pressed again
# Inside handle_enter_key method
def handle_enter_key
  if !@enter_inside
    @enter_inside = true
    @formula_editor.setpos(1, 20)
    @formula_editor.addstr("                                            ")
    @formula_editor.setpos(1, 20)
    # need to clear the grid cell of anything that was in it before
    @grid_window.setpos(@selected_cell[0] * 2 + 1, @selected_cell[1] * 8 + 2)
    @grid_window.addstr('      ')
    @grid_window.setpos(@selected_cell[0] * 2 + 1, @selected_cell[1] * 8 + 2)
    
    # if the cell is in the evaulated list we get rid of it then add the new thing we are typing
    @evaluated_list = @evaluated_list.select do |evaluated, cell|
      cell != @selected_cell
    end
    begin 
    # Get the current runtime variables associated with the cell
    if @runtime.grid.get_cell(Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1])) != nil
      cell = Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1])
      @runtime.variables = @evaluated_list.find { |evaluated, cell| cell == cell }[2]
    end
    rescue => e
      @formula_editor_cursor_y = 1
      @formula_editor_cursor_x = 20
      @formula_editor.setpos(@formula_editor_cursor_y, @formula_editor_cursor_x)
      @newline = false
    end
    # get the current runtime variables associated with the cell

    if @runtime.grid.get_cell(Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1])) != nil
      cell = Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1])
      @formula_editor.addstr(@runtime.grid.get_cell(cell).to_s)
      @amount_text_entered = (@runtime.grid.get_cell(cell).to_s).length
    end
    @formula_editor.refresh
  else
    @enter_inside = false
    # Exit formula editor mode
    @evaluated_list << [@runtime.grid.get_cell(Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1])), @selected_cell, @runtime.variables]
    @formula_editor.setpos(1, 20)
    @formula_editor.addstr("Press Enter to edit cell contents                         ")
    @formula_editor.refresh
    @amount_text_entered = 0
    draw_grid
  end
end
  # handle input text
  # putting it hopefully in the formula box
  def handle_input_text(input)
    if !@enter_inside
      draw_grid
      return
    end
    @amount_text_entered += 1
    @formula_editor.setpos(@formula_editor_cursor_y, @formula_editor_cursor_x)
    cell = Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1])
    if @runtime.grid.get_cell(cell) == nil
      @runtime.grid.set_cell(cell, input)
    else
      if !@newline
        @runtime.grid.set_cell(cell, @runtime.grid.get_cell(cell) + input)
        @amount_text_temp = @amount_text_entered
      else
        # only start getting the input from the next line which is the amount of text entered on
        text_to_cut = @runtime.grid.get_cell(cell)[@amount_text_temp..-1]
        if text_to_cut == nil
          text_to_cut = ""
        end
        @runtime.grid.set_cell(cell, text_to_cut + input)
      end
    end
    @formula_editor.addstr(@runtime.grid.get_cell(cell).to_s)
    draw_grid
    @formula_editor.refresh
  end
      
  def move_cursor(row_diff, col_diff)

    @display_panel.setpos(1, 20)
    # Removing the previous line length
    @display_panel.addstr("                                                                       ")
    new_row = @selected_cell[0] + row_diff
    new_col = @selected_cell[1] + col_diff
    
    new_row = [0, [new_row, @rows - 1].min].max
    new_col = [0, [new_col, @columns - 1].min].max
  
    @selected_cell = [new_row, new_col]

    # when we move hte cursor we want to update the formula editor
    # and the display panel to show the contents of the cell
    # we are currently on
    # we need to check if the first charecter is a = sign
    # else the thing is just a string
   begin
    cell_address = Primatives::CellAddress.new(@selected_cell[0], @selected_cell[1])
    if @runtime.grid.get_cell(cell_address) == nil
      @display_panel.setpos(1, 20)
      @display_panel.addstr(" ")
    elsif @runtime.grid.get_cell(cell_address)[0] == '='
      lexed = Lexer.new(@runtime.grid.get_cell(cell_address)).lex
      parsed = Parser.new(lexed, @runtime).parse
      evaluated = parsed.traverse(Evaluator.new, @runtime)
      if evaluated.nil?
        @display_panel.setpos(1, 20)
        @display_panel.addstr('Error')
      else
        @display_panel.setpos(1, 20)
        begin 
          @display_panel.addstr(evaluated.value.to_s)

        rescue => e
          if @runtime.variables[evaluated.to_s] != nil
            @display_panel.addstr(@runtime.variables[evaluated.to_s].value.to_s)
          else
            @display_panel.addstr(evaluated.to_s)
          end
        end
      end
    else
      # cast the string to an int or float to check if it can be convereted
      # if it can then we can display the value
      if @runtime.grid.get_cell(cell_address).to_i.is_a?(Integer) || @runtime.grid.get_cell(cell_address).to_f.is_a?(Float)
        lexed = Lexer.new(@runtime.grid.get_cell(cell_address)).lex
        parsed = Parser.new(lexed, @runtime).parse
        evaluated = parsed.traverse(Evaluator.new, @runtime)
        @display_panel.setpos(1, 20)
        if evaluated.nil?
          @display_panel.addstr('Error')
        else
          if @runtime.variables[evaluated.to_s] != nil
            @grid_window.addstr(@runtime.variables[evaluated.to_s].value.to_s)
            @display_panel.addstr(@runtime.variables[evaluated.to_s].value.to_s)
          else


            @grid_window.addstr(evaluated.to_s)
            @display_panel.addstr(evaluated.value.to_s)
          end

        end
      else
        @display_panel.setpos(1, 20)
        @display_panel.addstr(@runtime.grid.get_cell(cell_address).to_s)
        puts "here1?"

      end
     
    end
  rescue => e

  end
    draw_interface
  end
  

  def exit_application
    Curses.close_screen
    exit
  end
end

spreadsheet = Spreadsheet.new
spreadsheet.run

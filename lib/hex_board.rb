class HexBoard < Widget
  include ResourceBundle
  def initialize(x,y,z,width,height,columns,rows,window, initial_hex_state)
    super(x,y,z,width,height,window)
    @columns, @rows =
      columns,  rows
    HexSpace.initial_hex_state = initial_hex_state
    @hexes = Array.new(@rows)
    (0..(@rows-1)).each { |row| build_row(row) }
    @x_offset = x_overflow ? -1 * x_overflow/2 : 0
    @y_offset = y_overflow ? -1 * y_overflow/2 : 0
  end

  attr_accessor :hexes

  def build_row(row)
    @hexes[row]=Array.new(@columns)
    (0..(@columns-1)).each { |column| build_column_for_row(column, row) }
  end

  def build_column_for_row(column, row)
    x = column*column_width
    y = (row*row_height)+(((column%2)!=0) ? 0 : row_height/2)
    @hexes[row][column] = HexSpace.new(self, x, y, @z+1) unless row==@rows-1 && (column%2)==0
  end
  def clipped_draw
    b=ResourceBundle.background
    b.draw(@x,@y,@z,@width.to_f/b.width, @height.to_f/b.height)
    hexes.flatten.compact.each{|hex|hex.draw(@x+@x_offset,@y+@y_offset)}
  end

  def update
    return if @window.mouse_y < @y           ||
      @window.mouse_x < @x           ||
      @window.mouse_y > @y + @height ||
      @window.mouse_x > @x + @width
    border_width = 75
    move_board_left!  if @window.mouse_x > @x + @width - border_width
    move_board_right! if @window.mouse_x < @x + border_width
    move_board_down!  if @window.mouse_y < @y + border_width
    move_board_up!    if @window.mouse_y > @y + @height - border_width
  end

  def mouse_down(opts)
    register_click(opts[:x],opts[:y])
  end

  private
  def move_board_up!;    @y_offset -= [10,(@y_offset+y_overflow).abs].min if y_overflow > 0; end
  def move_board_down!;  @y_offset += [10,@y_offset.abs].min              if y_overflow > 0; end
  def move_board_left!;  @x_offset -= [10,(@x_offset+x_overflow).abs].min if x_overflow > 0; end
  def move_board_right!; @x_offset += [10,@x_offset.abs].min              if x_overflow > 0; end

  def column_width;      ((HEX_WIDTH*3)/4)-3;                      end
  def row_height;        HEX_HEIGHT-3;                             end
  def x_overflow;  (@columns*column_width)+(HEX_WIDTH/4)-@width;   end
  def y_overflow;  (@rows   *row_height  )               -@height; end

  def register_click(x,y)
    hex = hex_at(x,y)
    hex.state = @window.hex_palette.state_selected.state if hex && @window.hex_palette.state_selected
  end

  def r(p); ChunkyPNG::Color.r(p); end
  def g(p); ChunkyPNG::Color.g(p); end
  def b(p); ChunkyPNG::Color.b(p); end

  def hex_at(x,y)
    relative_x           = x - @x - @x_offset
    relative_y           = y - @y - @y_offset
    column = (relative_x                        / column_width).floor
    offset_due_to_column = column.even? ? (row_height/2) : 0
    row    = ( (relative_y - offset_due_to_column) / row_height  ).floor
    x_in_tile = relative_x - (column*column_width)
    y_in_tile = relative_y - ((row*row_height)+offset_due_to_column)
    pixel = ResourceBundle.mask.get_pixel(x_in_tile,y_in_tile)
    if r(pixel)     == 255 && g(pixel) == 255
      #bottom left
      column -= 1
      row += 1 if !column.even?
    elsif r(pixel)  == 255
      #top left
      column -= 1
      row -= 1 if column.even?
    elsif g(pixel)  == 255
      #bottom right
      column += 1
      row += 1 if !column.even?
    elsif b(pixel)  == 255
      #top right
      column += 1
      row -= 1 if column.even?
    end
    @hexes[row][column]
  end
end


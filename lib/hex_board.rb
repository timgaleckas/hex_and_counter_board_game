class HexBoard < Widget
  include ResourceBundle
  def initialize(x,y,z,width,height,window,options={})
    @columns, @rows, HexSpace.initial_hex_state =
      options.delete(:columns),
      options.delete(:rows),
      options.delete(:initial_hex_state)
    super
    @hexes = Array.new(@rows)
    (0..(@rows-1)).each { |row| build_row(row) }
    @x_scroll_offset = x_overflow ? -1 * x_overflow/2 : 0
    @y_scroll_offset = y_overflow ? -1 * y_overflow/2 : 0
  end

  attr_accessor :hexes

  def build_row(row)
    @hexes[row]=Array.new(@columns)
    (0..(@columns-1)).each { |column| build_column_for_row(column, row) }
  end

  def build_column_for_row(column, row)
    x = column*column_width
    y = (row*row_height)+(((column%2)!=0) ? 0 : row_height/2)+25
    hex_space = HexSpace.new(x, y, @z+1,HEX_WIDTH,HEX_HEIGHT,window,:board=>self)
    unless row==@rows-1 && (column%2)==0
      @hexes[row][column] = hex_space
      add_child_view hex_space
    end
  end
  def clipped_draw
    b=ResourceBundle.background
    b.draw(@x,@y,@z,@width.to_f/b.width, @height.to_f/b.height)
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
    child_views.each do |view|
      view.x_offset=@x_scroll_offset
      view.y_offset=@y_scroll_offset
    end
  end

  private
  def move_board_up!;    @y_scroll_offset -= [10,(@y_scroll_offset+y_overflow).abs].min if y_overflow > 0; end
  def move_board_down!;  @y_scroll_offset += [10,@y_scroll_offset.abs].min              if y_overflow > 0; end
  def move_board_left!;  @x_scroll_offset -= [10,(@x_scroll_offset+x_overflow).abs].min if x_overflow > 0; end
  def move_board_right!; @x_scroll_offset += [10,@x_scroll_offset.abs].min              if x_overflow > 0; end

  def column_width;      ((HEX_WIDTH*3)/4)-3;                      end
  def row_height;        HEX_HEIGHT-3;                             end
  def x_overflow;  (@columns*column_width)+(HEX_WIDTH/4)-@width;   end
  def y_overflow;  (@rows   *row_height  )               -@height; end

end


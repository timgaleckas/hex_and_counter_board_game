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
    grow
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
    b.draw(x+x_offset,y+y_offset,z,width.to_f/b.width, height.to_f/b.height)
  end

  private
  def column_width;      ((HEX_WIDTH*3)/4)-3;                      end
  def row_height;        HEX_HEIGHT-3;                             end

end


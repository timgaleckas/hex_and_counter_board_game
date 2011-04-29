class HexPalette
  def initialize(width, height, x, y, z, window)
    @x, @y, @z, @width, @height, @window =
     x,  y,  z,  width,  height,  window
  end
  attr_reader :hexes, :x, :y, :z, :width, :height
  def draw
    @window.clip_to(@x, @y, @width, @height) do
      b=ResourceBundle.background
      b.draw(@x,@y,@z,@width.to_f/b.width, @height.to_f/b.height)
      hexes.each{|hex|hex.draw(@x,@y)}
    end
  end
  def update
    @hexes = nil if hexes.size != ResourceBundle.hex_tiles.size
  end
  def hexes
    return @hexes if @hexes
    number_of_hexes_per_row = (@width / (ResourceBundle::HEX_WIDTH + 20)).floor
    xs = (1..number_of_hexes_per_row-1).map{|n| (((n.to_f/number_of_hexes_per_row)*@width)-(ResourceBundle::HEX_WIDTH/2)).floor}
    number_of_rows = (ResourceBundle.hex_tiles.size / number_of_hexes_per_row) + 1
    ys = (0..number_of_rows-1).map{|n| 20+(n*(ResourceBundle::HEX_HEIGHT+20)) }
    @hexes = []
    ys.each_with_index do |y,yi|
      xs.each_with_index do |x,xi|
        state = yi*xs.size+xi
        @hexes << HexSpace.new(nil,x,y,@z+1,yi*xs.size+xi) if state < ResourceBundle.hex_tiles.size
      end
    end
    @hexes
  end
  def mouse_click(opts={})
    ResourceBundle.tile_set = 'tile_set_1'
    true
  end
end

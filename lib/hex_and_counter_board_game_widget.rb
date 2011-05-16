class HexAndCounterBoardGameWidget < Widget
  def initialize(x,y,z,width,height,window,options={})
    options = {
      :tile_set          => "default",
      :columns           => 15,
      :rows              => 22,
      :initial_hex_state => 0
    }.merge(options)
    super(x,y,z,width,height,window)
    add_child_view GameMenu.new(    width-600, y,        99, 600,       45,         window)
    @hex_board = HexBoard.new(    x,         y,         z, width-600, height,     window, options)
    add_child_view @hex_board
    @hex_palette = add_child_view HexPalette.new(  width-600, y+45,      z, 600,       365,        window)
    add_child_view CounterTray.new( width-600, y+45+356,  z, 600,       height-425, window)
    add_child_view CounterPiece.new( 100, 100,  z+99, 100, 100, window)
  end

  attr_reader :hex_palette

  def button_down(id)
    close if id == Gosu::KbEscape
  end
end


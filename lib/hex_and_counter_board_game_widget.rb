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
    @hex_board = HexBoard.new(              x,    y,      z, width-600, height,     window, options)
    add_child_view ScrollPanel.new(         x,    y,      z, width-600, height,     window, :child_views=> [@hex_board])
    @hex_palette = HexPalette.new(  width-600, y+45,      z, 600,       365,        window)
    add_child_view ScrollPanel.new( width-600, y+45,      z, 600,       365,        window, :child_views=> [@hex_palette])

    add_child_view CounterTray.new( width-600, y+45+356,  z, 600,       height-425, window)
  end

  attr_reader :hex_palette

  def button_down(id)
    close if id == Gosu::KbEscape
  end
end


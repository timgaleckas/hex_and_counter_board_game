class ResourceBundle
  HEX_WIDTH  = 100
  HEX_HEIGHT = 100
  class << self
    def load(window, tile_set)
      @window = window
      @hex_tiles = nil
      @tile_set = tile_set
      #eager load
      [hex_tiles,cursor]
    end
    def tile_set=(tile_set)
      load(@window,tile_set)
    end
    def hex_tiles
      return @hex_tiles if @hex_tiles
      square_tiles = Gosu::Image.load_tiles(@window, "resources/tile_sets/#{@tile_set}/hexes.png", HEX_WIDTH, HEX_HEIGHT, true)
      @hex_tiles = square_tiles.map{ |tile| tile.mask(@window,hex_overlay,mask) }
    end

    def hex_overlay; @hex_overlay ||= Magick::Image.read(      'resources/images/hex_outline.png').first; end
    def mask;        @mask        ||= Magick::Image.read(       'resources/images/hex_mask.png').first;   end
    def background;  @background  ||= Gosu::Image.new(@window, 'resources/images/background.png', true);  end
    def cursor;      @cursor      ||= Gosu::Image.new(@window, 'resources/images/cursor.png');            end
  end
end

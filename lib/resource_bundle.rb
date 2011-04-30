module ResourceBundle
  HEX_WIDTH    = 100
  HEX_HEIGHT   = 100
  IMAGES_DIR   = 'resources/images'
  TILE_SET_DIR = 'resources/tile_sets'
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
      @hex_tiles = Gosu::Image.load_tiles(@window, "resources/tile_sets/#{@tile_set}/hexes.png", HEX_WIDTH, HEX_HEIGHT, true)
    end

    def hex_check_box;   @hex_uncheck  ||= Gosu::Image.new(@window, 'resources/images/hex_check_box.png');     end
    def hex_uncheck_box; @hex_check    ||= Gosu::Image.new(@window, 'resources/images/hex_uncheck_box.png');   end
    def background;      @background   ||= Gosu::Image.new(@window, 'resources/images/background.png', true);  end
    def cursor;          @cursor       ||= Gosu::Image.new(@window, 'resources/images/cursor.png');            end
    def mask;            @mask         ||= ChunkyPNG::Image.from_file('resources/images/hex_mask.png');        end
  end
end

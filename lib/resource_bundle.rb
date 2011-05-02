module ResourceBundle
  HEX_WIDTH      = 80
  HEX_HEIGHT     = 80
  COUNTER_WIDTH  = 48
  COUNTER_HEIGHT = 48
  IMAGES_DIR   = 'resources/images'
  TILE_SET_DIR = 'resources/tile_sets'
  class << self
    def load(window, tile_set='default', counter_set='default')
      @window      = window
      @hex_tiles   = nil
      @tile_set    = tile_set
      @counter_set = counter_set
      #eager load
      [hex_tiles,counter_tiles,cursor]
    end
    def tile_set=(tile_set)
      load(@window,tile_set)
    end
    def hex_tiles
      return @hex_tiles if @hex_tiles
      @hex_tiles = Gosu::Image.load_tiles(@window, "resources/tile_sets/#{@tile_set}/hexes.png", HEX_WIDTH, HEX_HEIGHT, true)
    end

    def counter_tiles
      return @counter_tiles if @counter_tiles
      @counter_tiles = Gosu::Image.load_tiles(@window, "resources/counter_sets/#{@counter_set}.png", COUNTER_WIDTH, COUNTER_HEIGHT, true).each_slice(2).to_a
    end

    def hex_check_box;   @hex_uncheck  ||= Gosu::Image.new(@window, 'resources/images/hex_check_box.png');     end
    def hex_uncheck_box; @hex_check    ||= Gosu::Image.new(@window, 'resources/images/hex_uncheck_box.png');   end
    def background;      @background   ||= Gosu::Image.new(@window, 'resources/images/background.png', true);  end
    def cursor;          @cursor       ||= Gosu::Image.new(@window, 'resources/images/cursor.png');            end
    def mask;            @mask         ||= ChunkyPNG::Image.from_file('resources/images/hex_mask.png');        end
  end
end

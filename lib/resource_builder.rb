class ResourceBuilder
  class << self
    include Magick
    include ResourceBundle

    def create_hex_mask
      w = HEX_WIDTH
      h = HEX_HEIGHT
      mask = Image.new(w,h) {self.background_color = "black"}
      clip = Draw.new
      clip.stroke('none')
      clip.fill('red')
      clip.polygon(
              0,   0,
            w/4,   0,
              0, h/2
      )
      clip.fill('blue')
      clip.polygon(
        (w*3)/4,   0,
              w,   0,
              w, h/2
      )
      clip.fill('green')
      clip.polygon(
              w, h/2,
              w,   h,
        (w*3)/4,   h
      )
      clip.fill('yellow')
      clip.polygon(
            w/4,   h,
              0,   h,
              0, h/2
      )
      clip.draw(mask)
      mask.write("#{IMAGES_DIR}/hex_mask.png")
      Image.read("#{IMAGES_DIR}/hex_mask.png").first
    end

    def create_hex_overlay
      w,h,s = HEX_WIDTH, HEX_HEIGHT, 6
      overlay = Image.new(w,h) { self.background_color = "black" }
      clip = Draw.new
      clip.stroke('none')
      clip.fill('white')
      s2 = (s*3)/4
      p = points = [
        ((w*3)/4)-s2, 0+s2,
        w-s,           h/2,
        ((w*3)/4)-s2, h-s2,
        (w/4)+s2,     h-s2,
        0+s,           h/2,
        (w/4)+s2,     0+s2,
      ]
      clip.polygon(*(points[0..5]))
      clip.polygon(*(points[6..11]))
      clip.polygon(p[0],p[1],p[4],p[5],          p[10],p[11])
      clip.polygon(          p[4],p[5],p[6],p[7],p[10],p[11])
      clip.draw(overlay)
      overlay.transparent('white').write("#{IMAGES_DIR}/hex_overlay.png")
      Image.read("#{IMAGES_DIR}/hex_overlay.png").first
    end

    def write_tile_set_hexes(name,number_of_tiles,from_color,to_color)
      w, h = HEX_WIDTH, HEX_HEIGHT
      number_of_columns = Math.sqrt(number_of_tiles).to_i
      number_of_rows    = (number_of_tiles.to_f / number_of_columns).ceil
      width             = w*number_of_columns
      height            = h*number_of_rows
      tile_set          = Image.new(width,height){ self.background_color = 'black' }
      gradient          = tile_set.sparse_color(BarycentricColorInterpolate,0,0,from_color,width,0,to_color)
      drawing           = Draw.new
      drawing.stroke('none')
      (0..number_of_rows-1).each do |row|
        (0..number_of_columns-1).each do |column|
          index = (row*number_of_columns)+column
          color = gradient.pixel_color((((index+1).to_f/number_of_tiles)*width).floor,0).to_color
          drawing.fill(color)
          x = column*w
          y = row*h
          drawing.rectangle(x,y,x+w,y+h)
        end
      end
      drawing.draw(tile_set)
      FileUtils.mkdir_p("#{TILE_SET_DIR}/#{name}")
      tile_set.write("#{TILE_SET_DIR}/#{name}/hexes.png")
    end
    def clean_hexes(tile_set_name)
      window       = Gosu::Window.new(1,1,1)
      mask         = find_or_create_hex_mask
      hex_overlay  = find_or_create_hex_overlay
      hexes        = tile_set_name.is_a?(String) ? Image.read("#{TILE_SET_DIR}/#{tile_set_name}/hexes.png").first : tile_set_name
      new_hexes    = ImageList.new
      square_tiles = Gosu::Image.load_tiles(window, hexes, HEX_WIDTH, HEX_HEIGHT, true)
      hex_tiles    = square_tiles.map{ |tile| tile.mask(window,hex_overlay,mask) }
      rows         = hexes.rows/HEX_HEIGHT
      columns      = hexes.columns/HEX_WIDTH

      rows.times do |i|
        hex_row = ImageList.new
        columns.times do |j|
          hex_row << hex_tiles[i*columns+j].to_rmagick
        end
        new_hexes << hex_row.append(false)
      end
      new_hexes = new_hexes.append(true)
      if tile_set_name.is_a?(String)
        new_hexes.write("#{TILE_SET_DIR}/#{tile_set_name}/hexes.png")
      end
      new_hexes
    end

    def create_or_clean_tile_set(tile_set_name)
      if tile_set_name.is_a?(String) && !File.exists?("#{TILE_SET_DIR}/#{tile_set_name}/hexes.png")
        write_tile_set_hexes(tile_set_name,9,'#c4da6b','#456c4b')
      end
      clean_hexes(tile_set_name)
    end

    def find_or_create_hex_mask
      begin; Image.read('resources/images/hex_mask.png').first;    rescue; create_hex_mask;    end
    end
    def find_or_create_hex_overlay
      begin; Image.read('resources/images/hex_overlay.png').first; rescue; create_hex_overlay; end
    end


    def create_hexes_from_map(options={})
      display       = options[:display]
      file_name     = options[:file_name]
      tile_set_name = options[:tile_set_name]
      raise 'required' if file_name.nil?
      r =  options[:rotation]     || 0
      x1 = options[:trim_left]    || 0
      y1 = options[:trim_top]     || 0
      x2 = options[:trim_right]   || 0
      y2 = options[:trim_bottom]  || 0
      w =  options[:hex_width]    || HEX_WIDTH
      h =  options[:hex_height]   || HEX_HEIGHT
      first_row_short = options[:first_row_short] #the first row of tiles starts off _-_-_ instead of -_-_-_
      image = Image.read(file_name).first.rotate!(r)
      image.crop!(x1,y1,image.columns-x1-x2,image.rows-y1-y2)
      tiles = ImageList.new
      current_y = 0
      while current_y+h < image.rows+10
        row = ImageList.new
        current_x = 0
        y_offset = first_row_short
        while current_x+w < image.columns+10
          row << image.excerpt(current_x,current_y+(y_offset ? h/2 : 0),w,h).resize!(HEX_HEIGHT,HEX_WIDTH)
          current_x += 0.76*w
          y_offset = !y_offset
        end
        tiles << row.append(false)
        current_y += h
      end
      hexes = tiles.append(true)
      if display
        hexes.display
      end
      if tile_set_name
        FileUtils.mkdir_p("#{TILE_SET_DIR}/#{tile_set_name}")
        hexes.write("#{TILE_SET_DIR}/#{tile_set_name}/hexes.png")
      end
      hexes
    end

    def create_counter_set_from_files(directory, extension, output_file)
      all_counters = Dir.glob("#{directory}/*.#{extension}")
      counters     = all_counters.reject{|file|file =~ /-disabled/ || file =~ /blank/}.map do |file|
        disabled_name = file.sub(".#{extension}","-disabled.#{extension}")
        [file,all_counters.include?(disabled_name) ? disabled_name : file ]
      end
      counter_tiles = counters.inject(ImageList.new) do |row_set, counter_files|
        row_set << counter_files.inject(ImageList.new) do |row, file|
          row << Image.read(file).first
          row
        end.append(false)
        row_set
      end.append(true).write("#{output_file}.png")
    end
  end
end

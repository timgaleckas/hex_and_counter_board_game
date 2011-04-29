class ResourceBuilder
  class << self

    #currently at 100,100
    def write_hex_mask_file(w,h)
      mask = Magick::Image.new(w,h) {self.background_color = "black"}
      clip = Magick::Draw.new
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
      mask.write('resources/images/hex_mask.png')
    end

    #currently at 100,100,6
    def write_hex_outline_file(w,h,stroke_weight)
      mask = Magick::Image.new(w,h) {
        self.background_color = "black"
      }
      clip = Magick::Draw.new
      clip.stroke('none')
      clip.fill('white')
      s = stroke_weight
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
      clip.draw(mask)
      mask.transparent('white').write('resources/images/hex_outline.png')
    end

    #currently 100,100,9,c4da6b,456c4b
    def write_default_tile_set(w,h,number_of_tiles,from_color,to_color)
      number_of_columns = Math.sqrt(number_of_tiles).to_i
      number_of_rows    = (number_of_tiles.to_f / number_of_columns).ceil
      width             = w*number_of_columns
      height            = h*number_of_rows
      tile_set          = Magick::Image.new(width,height){ self.background_color = 'black' }
      gradient          = tile_set.sparse_color(Magick::BarycentricColorInterpolate,0,0,from_color,width,0,to_color)
      drawing = Magick::Draw.new
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
      FileUtils.mkdir_p('resources/tile_sets/default')
      tile_set.write('resources/tile_sets/default/hexes.png')
    end

  end
end

class CounterPiece < Widget
  def clipped_draw
    ResourceBundle.counter_tiles[0].draw(x,y,z)
  end
end

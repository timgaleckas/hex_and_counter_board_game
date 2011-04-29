class Gosu::Image
  def to_rmagick
    this = self
    Magick::Image.from_blob(to_blob) do
      self.format = 'RGBA'
      self.depth = 8
      self.size = "#{this.width}x#{this.height}"
    end.first
  end
  def mask(window, overlay, mask)
    rmagick_image = self.to_rmagick
    rmagick_image = rmagick_image.composite(overlay, Magick::CenterGravity, Magick::OverCompositeOp)
    rmagick_image.add_compose_mask(mask)
    return Gosu::Image.new(window, rmagick_image.composite(mask, Magick::CenterGravity, Magick::OutCompositeOp))
  end
end

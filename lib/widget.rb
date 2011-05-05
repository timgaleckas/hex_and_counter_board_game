class Widget
  include ResourceBundle
  def initialize(x,y,z,width,height,window,options={})
    options = {
      :display => true,
      :child_views_clipped => true
    }.merge(options)
    @x, @y, @z, @width, @height, @window, @child_views,   @display =
     x,  y,  z,  width,  height,  window,  SortedSet.new,  options.delete(:display)
  end
  attr_reader   :x, :y, :z, :width, :height, :window, :child_views
  attr_accessor :display, :parent_view
  def draw
    if display
      window.clip_to(x, y, width, height) do
        clipped_draw
        child_views.each do |child_view|
          child_view.draw
        end
      end
    end
  end
  def clipped_draw
  end
  def update
    if display
      child_views.each do |child_view|
        child_view.update
      end
    end
  end
  def clipped_draw; end
  def add_child_view(child_view)
    self.child_views << child_view
    child_view.parent_view = self
    child_view
  end
  def <=>(other)
    other.z <=> z
  end
end

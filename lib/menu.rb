class Menu < Widget
  include Gosu

  attr_reader   :items, :parent, :title
  attr_accessor :selected

  X_PADDING = 30
  Y_PADDING = 16

  def initialize(x,y,z,width,height,window,options={})
    @title               = options.delete(:title)
    @action              = options.delete(:action)
    @insertion_direction = options.delete(:direction)       || :vertical
    @parent              = options.delete(:parent)
    super
    @width  = image.width  + X_PADDING if image
    @height = image.height + Y_PADDING if image
    insertion_x = self.x
    insertion_y = self.y
    insertion_x += self.width  if @title && @insertion_direction == :horizontal
    insertion_y += self.height if @title && @insertion_direction == :vertical
    @insertion_point     = [insertion_x,insertion_y]
    @items     = []
  end
  def mouse_down(options)
    @action.call(self) if @action
    self.selected = !self.selected
    false
  end
  def image
    return nil unless @title
    @image ||= Image.from_text(window,@title,'Verdana',25)
  end
  def clipped_draw
    c = Color.new(0,0,0)
    window.draw_quad(x, y, c, x+width, y, c, x, y+height, c, x+width, y+height, c, z) if @title
    image && image.draw(x+(X_PADDING/2),y+(Y_PADDING/2),z+2)
  end
  def add_item(title, &action)
    item_x, item_y = *@insertion_point
    @items.each do |sm|
      item_x+=sm.width  if @insertion_direction == :horizontal
      item_y+=sm.height if @insertion_direction == :vertical
    end
    Menu.new(item_x,item_y,z+1,nil,height,window,
             :title           => title,
             :action          => block_given? ? action : nil,
             :display         => false,
             :parent          => self,
             :insertion_point => [item_x,item_y]).tap do |sm|
      @items << sm
      child_views << sm
      pad_menu_items
    end
  end
  def display
    parent.nil? || parent.title.nil? || parent.selected
  end
  def height
    if self.selected && @items.last
      @items.map{|i|i.y+i.height}.max - self.y
    else
      super
    end
  end
  def width
    if self.selected && @items.last
      @items.map{|i|i.x+i.width}.max - self.x
    else
      super
    end
  end
  attr_writer :width, :height
  private
  def pad_menu_items
    if @insertion_direction == :horizontal
      max_height = (child_views+[self]).map{|i|i.height}.max
      child_views.each{|i|i.height=max_height}
    else
      max_width = (child_views+[self]).map{|i|i.width}.max
      child_views.each{|i|i.width=max_width}
    end
  end
end

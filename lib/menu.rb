class Menu < Widget
  include Gosu

  attr_accessor :display
  attr_reader   :items
  X_PADDING = 20
  Y_PADDING = 10
  def initialize(x,y,z,width,height,window,options={})
    @title               = options.delete(:title)
    @action              = options.delete(:action)
    @insertion_direction = options.delete(:direction)       || :vertical
    @display             = options.delete(:display)
    super
    insertion_x = x
    insertion_y = y
    insertion_x += height + Y_PADDING if @title && @insertion_direction == :vertical
    insertion_y += width  + X_PADDING if @title && @insertion_direction == :horizontal
    @insertion_point     = [insertion_x,insertion_y]
    @items     = []
  end
  def mouse_down(options)
    @action.call(self) if @action
  end
  def image
    return nil unless @title
    @image ||= Image.from_text(window,@title,'Verdana',200)
  end
  def width
    return super unless @title
    ((height.to_f/image.height)*image.width)+X_PADDING
  end
  def draw
    c = Color.new(0,0,0)
    window.draw_quad(x, y, c, x+width, y, c, x, y+height, c, x+width, y+height, c, z) if @title
    image && image.draw(x+X_PADDING,y,z+2,width.to_f/image.width,height.to_f/image.height)
    if @display
      mins = nil
      @items.each do |sm|
        if mins.nil?
          mins = [sm.x, sm.y, sm.x+width, sm.y+height ]
        else
          mins[0] = [sm.x        ,mins[0]].min
          mins[1] = [sm.y        ,mins[1]].min
          mins[2] = [sm.x+width  ,mins[2]].max
          mins[3] = [sm.y+height ,mins[3]].max
        end
        sm.draw
      end
      if mins
        min_x = mins[0]
        min_y = mins[1]
        max_x = mins[2] + X_PADDING
        max_y = mins[3] + Y_PADDING

        window.draw_quad(min_x,min_y,c,
                         max_x,min_y,c,
                         min_x,max_y,c,
                         max_x,max_y,c, z-1)
      end
    end
  end
  def add_item(title, &action)
    item_x, item_y = *@insertion_point
    if @title
      item_x+=width+X_PADDING   if @insertion_direction == :horizontal
      item_y+=height+Y_PADDING  if @insertion_direction == :vertical
    end
    @items.each do |sm|
      item_x+=sm.width+X_PADDING   if @insertion_direction == :horizontal
      item_y+=sm.height+Y_PADDING  if @insertion_direction == :vertical
    end
    Menu.new(item_x,item_y,z,nil,height,window,:title=>title,:action=>action,:insertion_point=>[item_x,item_y]).tap{|sm|@items << sm}
  end
  def child_input_clients
    @display ? @items : []
  end
  def undisplay_all
    @display = false
    @items.each{|i|i.undisplay_all}
  end
end

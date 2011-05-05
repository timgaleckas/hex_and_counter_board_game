class GameMenu < Menu
  def initialize(x,y,z,width,height,window,options={})
    super(x,y,z,width,height,window, :direction=>:horizontal)
    menu = self
    tile_sets_sub_menu  = add_item('Tile Sets')
    ResourceBundle.available_tile_sets.each do |tile_set|
      tile_sets_sub_menu.add_item(tile_set) do
        ResourceBundle.load(window,tile_set)
      end
    end
    add_item('Counter Sets').add_item('default')
    add_item('Exit') do
      window.close
    end
  end
end


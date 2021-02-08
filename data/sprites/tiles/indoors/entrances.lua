-- Entrance Tile Sprites
return function(SpriteBank)
  local register = SpriteBank.registerSprite
  local sb = SpriteBank.createSpriteBuilder()
  
  -- Bases
  sb:setSpriteSheet('wall_columns_vertical')
  register('wall_down_column_left_cave', sb:buildSprite(1, 1))
  register('wall_down_column_left_interior', sb:buildSprite(2, 1))
  register('wall_down_column_left_subrosia', sb:buildSprite(3, 1))
  register('wall_down_column_left_temple', sb:buildSprite(4, 1))
  register('wall_down_column_left_palace', sb:buildSprite(5, 1))
  
  register('wall_down_column_right_cave', sb:buildSprite(1, 2))
  register('wall_down_column_right_interior', sb:buildSprite(2, 2))
  register('wall_down_column_right_subrosia', sb:buildSprite(3, 2))
  register('wall_down_column_right_temple', sb:buildSprite(4, 2))
  register('wall_down_column_right_palace', sb:buildSprite(5, 2))
  
  register('wall_up_column_left_cave', sb:buildSprite(1, 3))
  register('wall_up_column_left_interior', sb:buildSprite(2, 3))
  register('wall_up_column_left_subrosia', sb:buildSprite(3, 3))
  register('wall_up_column_left_temple', sb:buildSprite(4, 3))
  register('wall_up_column_left_palace', sb:buildSprite(5, 3))
  
  register('wall_up_column_right_cave', sb:buildSprite(1, 4))
  register('wall_up_column_right_interior', sb:buildSprite(2, 4))
  register('wall_up_column_right_subrosia', sb:buildSprite(3, 4))
  register('wall_up_column_right_temple', sb:buildSprite(4, 4))
  register('wall_up_column_right_palace', sb:buildSprite(5, 4))
  
  sb:setSpriteSheet('wall_columns_horizontal')
  register('wall_left_column_top_cave', sb:buildSprite(1, 1))
  register('wall_left_column_top_interior', sb:buildSprite(2, 1))
  register('wall_left_column_top_subrosia', sb:buildSprite(3, 1))
  register('wall_left_column_top_temple', sb:buildSprite(4, 1))
  register('wall_left_column_top_palace', sb:buildSprite(5, 1))
  
  register('wall_left_column_bottom_cave', sb:buildSprite(1, 2))
  register('wall_left_column_bottom_interior', sb:buildSprite(2, 2))
  register('wall_left_column_bottom_subrosia', sb:buildSprite(3, 2))
  register('wall_left_column_bottom_temple', sb:buildSprite(4, 2))
  register('wall_left_column_bottom_palace', sb:buildSprite(5, 2))
  
  register('wall_right_column_top_cave', sb:buildSprite(1, 3))
  register('wall_right_column_top_interior', sb:buildSprite(2, 3))
  register('wall_right_column_top_subrosia', sb:buildSprite(3, 3))
  register('wall_right_column_top_temple', sb:buildSprite(4, 3))
  register('wall_right_column_top_palace', sb:buildSprite(5, 3))
  
  register('wall_right_column_bottom_cave', sb:buildSprite(1, 4))
  register('wall_right_column_bottom_interior', sb:buildSprite(2, 4))
  register('wall_right_column_bottom_subrosia', sb:buildSprite(3, 4))
  register('wall_right_column_bottom_temple', sb:buildSprite(4, 4))
  register('wall_right_column_bottom_palace', sb:buildSprite(5, 4))
  
  -- Tiles
  sb:setSpriteSheet('entrance_columns')
  register('entrance_column_bottom_down', sb:buildSprite(1, 1))
  
end

-- Cracked Floors Tile Sprites
return function(SpriteBank)
  local register = SpriteBank.registerSprite
  local sb = SpriteBank.createSpriteBuilder()
  sb:setSpriteSheet('cracked_floors')
  
  register('pattern_1', sb:buildSprite(1, 1))
  register('pattern_1_checkered', sb:buildSprite(1, 2))
  register('pattern_2', sb:buildSprite(1, 3))
  register('pattern_3', sb:buildSprite(1, 4))
  register('pattern_4', sb:buildSprite(2, 1))
  register('pattern_5', sb:buildSprite(2, 2))
  register('pattern_5_dark', sb:buildSprite(2, 3))
  register('pattern_6', sb:buildSprite(2, 4))
  register('pattern_7', sb:buildSprite(3, 1))
  register('pattern_7_dark', sb:buildSprite(3, 2))
  register('pattern_8', sb:buildSprite(3, 3))
  register('interior', sb:buildSprite(3, 4))
  register('brick_northeast', sb:buildSprite(4, 1))
  register('brick_northwest', sb:buildSprite(4, 2))
end


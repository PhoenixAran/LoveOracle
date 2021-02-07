-- Interior Sprites

return function(SpriteBank)
  local sb = SpriteBank.createSpriteBuilder()
  local register = SpriteBank.registerSprite
  
  sb:setSpriteSheet('interior')
  
  register('tile_wardrobe_top', sb:buildSprite(1, 1))
  
  
end
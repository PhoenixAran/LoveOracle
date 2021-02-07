-- Cracked Floors Sprites
return function(SpriteBank)
  local register = SpriteBank.register
  local sb = SpriteBank.createSpriteBuilder()
  sb:setSpriteSheet('cracked_floors')
  
  register('pattern_1', sb:createSprite(1, 1))
  register('pattern_1_checkered', sb:createSprite(1, 2))
  register('pattern_2', sb:createSprite(1, 3))
  register('pattern_3', sb:createSprite(1, 4))
  register('pattern_4', sb:createSprite(2, 1))
  register('pattern_5', sb:createSprite(2, 2))
  register('pattern_5_dark', sb:createSprite(2, 3))
  register('pattern_6', sb:createSprite(2, 4))
  register('pattern_7', sb:createSprite(3, 1))
  register('pattern_7_dark', sb:createSprite(3, 2))
  register('pattern_8', sb:createSprite(3, 3))
  register('interior', sb:createSprite(3, 4))
  register('brick_northeast', sb:createSprite(4, 1))
  register('brick_northwest', sb:createSprite(4, 2))

end


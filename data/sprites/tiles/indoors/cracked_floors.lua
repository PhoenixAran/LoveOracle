-- Cracked Floors Tile Sprites
return function(SpriteBank)
  local sb = SpriteBank.createSpriteBuilder()
  local spriteset = SpriteBank.createSpriteset('cracked_floors', 4, 4)
  local register = SpriteBank.registerSpriteset
  -- this is a one to one conversion of tileset to spriteset
  -- lets make this helper to make the code more readable
  local set = function(name, x, y)
    spriteset:setSprite(name, sb:buildSprite(x, y), x, y)
  end
  
  sb:setSpriteSheet('cracked_floors')
  
  set('pattern_1', 1, 1)
  set('pattern_1_checkered', 1, 2)
  set('pattern_2', 1, 3)
  set('pattern_3', 1, 4)
  set('pattern_4', 2, 1)
  set('pattern_5', 2, 2)
  set('pattern_5_dark', 2, 3)
  set('pattern_6', 2, 4)
  set('pattern_7', 3, 1)
  set('pattern_7_dark', 3, 2)
  set('pattern_8', 3, 3)
  set('interior', 3, 4)
  set('brick_northeast', 4, 1)
  set('brick_northwest', 4, 2)
  
  register(spriteset)
end


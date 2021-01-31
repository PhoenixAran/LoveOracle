-- prototype tile sprites
return function(SpriteBank)
  local PrototypeSprite = require 'engine.graphics.prototype_sprite'
  SpriteBank.registerSprite('prototype_ground_tile', PrototypeSprite(0, 1, 0, 16, 16))
  SpriteBank.registerSprite('prototype_ice_tile', PrototypeSprite(163 / 255, 216 / 255, 230 / 255, 16, 16))
  SpriteBank.registerSprite('prototype_hole_tile', PrototypeSprite(0, 0, 0, 16, 16))
  SpriteBank.registerSprite('prototype_water_tile', PrototypeSprite(0, 0, 1, 16, 16))
end
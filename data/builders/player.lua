-- PLAYER
local key = player
local builder = { }

local SpriteRenderer = require 'engine.components.animated_sprite_renderer'

function builder.create()
  local spriteSheet = spriteSheets['player']
  
  return key, nil
end


return builder
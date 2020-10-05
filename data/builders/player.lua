-- PLAYER
local key = 'player'
local builder = { }

local SpriteRenderer = require 'engine.components.animated_sprite_renderer'

function builder.build()
  local spriteSheet = assetManager.getSpriteSheet('player')
  print('playerbuilder.create')
  return key, nil
end


return builder
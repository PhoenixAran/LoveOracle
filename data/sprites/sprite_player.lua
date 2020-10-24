-- player sprites
local builder = { }

function builder.fillPayload(payload)
  
end

function builder.configureSpriteBuilder(builder)
  local sb = require('engine.utils.sprite_animation_builder')()
  
  -- placeholder animations
  sb:setSpriteSheet('player')
  sb:setDefaultLoopType('cycle', true)
  -- placeholder animations
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('idle', sb:build())
  builder:setDefaultAnimation('idle')
  
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('aim', sb:build())
  
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('throw', sb:build())
  
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('swing', sb:build())
  
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('swingNoLunge', sb:build())
  
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('swingBig', sb:build()) 
  
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('spin', sb:build()) 
  
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('stab', sb:build())
  
  sb:addPrototypeFrame(0, 1, 0, 16, 16, 0, 0)
  builder:addAnimation('carry', sb:build())
  

end

function builder.getKey()
  return 'player'
end

return builder 
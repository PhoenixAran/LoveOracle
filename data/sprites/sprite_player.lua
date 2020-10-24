-- player sprites
local builder = { }

function builder.fillPayload(payload)
  
end

function builder.configureSpriteBuilder(builder)
  builder:setDefaultAnimation('idle')
  local sb = require('engine.utils.sprite_animation_builder')()
  
  -- placeholder animations
  sb:setSpriteSheet('player')
  sb:setDefaultLoopType('cycle', true)
  -- placeholder animations
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('idle', sb:build())

  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('walk', sb:build())
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('jump', sb:build())
  
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('aim', sb:build())
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('throw', sb:build())
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('swing', sb:build())
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('swingNoLunge', sb:build())
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('swingBig', sb:build()) 
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('spin', sb:build()) 
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('stab', sb:build())
  
  sb:addPrototypeFrame(.662, .451, .662, 16, 16, 0, 0)
  builder:addAnimation('carry', sb:build())
  

end

function builder.getKey()
  return 'player'
end

return builder 
-- player sprites
local playerSpriteBuilder = { }

function playerSpriteBuilder.configureSpriteBuilder(builder)
  builder:setDefaultAnimation('idle')
  local sb = builder:createSpriteAnimationBuilder()
  
  -- sprite animation builder setup
  sb:setSpriteSheet('player')
  sb:setDefaultLoopType('cycle')
  
  -- @animation idle
  sb:setSubstrips(true)
  -- #substrip up
  sb:addSpriteFrame(1, 3)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(1, 7)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(1, 5)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(1, 1)
  sb:buildSubstrip('right')
  -- BUILD idle
  builder:addAnimation('idle', sb:build())
  
  -- @animation walk
  sb:setSubstrips(true)
  -- #substrip up
  sb:addSpriteFrame(1, 4)
  sb:addSpriteFrame(1, 3)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(1, 8)
  sb:addSpriteFrame(1, 7)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(1, 6)
  sb:addSpriteFrame(1, 5)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(1, 2)
  sb:addSpriteFrame(1, 1)
  sb:buildSubstrip('right')
  -- BUILD walk
  builder:addAnimation('walk', sb:build())
  
  -- @animation jump
  sb:setSubstrips(true)
  -- #substrip up
  sb:addSpriteFrame(12, 4)
  sb:addSpriteFrame(12, 5)
  sb:addSpriteFrame(12, 6)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(13, 4)
  sb:addSpriteFrame(13, 5)
  sb:addSpriteFrame(13, 6)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(13, 1)
  sb:addSpriteFrame(13, 2)
  sb:addSpriteFrame(13, 3)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(12, 1)
  sb:addSpriteFrame(12, 2)
  sb:addSpriteFrame(12, 3)
  sb:buildSubstrip('right')
  -- BUILD jump
  builder:addAnimation('jump', sb:build())
  
  -- @animation sword_swing
  sb:setSubstrips(true)
  -- #substrip up
  sb:addSpriteFrame(9, 4, 0, 0, 3)
  sb:addSpriteFrame(5, 3, 0, 0, 3)
  sb:addSpriteFrame(5, 3, 0, -4, 8)
  sb:addSpriteFrame(5, 3, 0, 0, 3)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(9, 2, 0, 0, 3)
  sb:addSpriteFrame(5, 7, 0, 0, 3)
  sb:addSpriteFrame(5, 7, 0, 4, 8)
  sb:addSpriteFrame(5, 7, 0, 0, 3)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(9, 3, 0, 0, 3)
  sb:addSpriteFrame(5, 5, 0, 0, 3)
  sb:addSpriteFrame(5, 5, -4, 0, 8)
  sb:addSpriteFrame(5, 5, 0, 0, 3)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(9, 5, 0, 0, 3)
  sb:addSpriteFrame(5, 1, 0, 0, 3)
  sb:addSpriteFrame(5, 1, 4, 0, 8)
  sb:addSpriteFrame(5, 1, 0, 0, 3)
  sb:buildSubstrip('right')
  -- BUILD sword_swing
  builder:addAnimation('sword_swing', sb:build())
end

function playerSpriteBuilder.placeholderAnimations(builder)
  builder:setDefaultAnimation('idle')
  local sb = builder:createSpriteAnimationBuilder()
  
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

function playerSpriteBuilder.getKey()
  return 'player'
end

return playerSpriteBuilder 
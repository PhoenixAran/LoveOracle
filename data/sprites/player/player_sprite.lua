-- player sprites
return function(spriteBank)
  local builder = spriteBank.createSpriteRendererBuilder()
  local sb = spriteBank.createSpriteAnimationBuilder()
  
  builder:setDefaultAnimation('idle')
  builder:setFollowZ(true)
  
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
  sb:addSpriteFrame(12, 4, 0, 0, 9)
  sb:addSpriteFrame(12, 5, 0, 0, 9)
  sb:addSpriteFrame(12, 6, 0, 0, 9)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(13, 4, 0, 0, 9)
  sb:addSpriteFrame(13, 5, 0, 0, 9)
  sb:addSpriteFrame(13, 6, 0, 0, 9)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(13, 1, 0, 0, 9)
  sb:addSpriteFrame(13, 2, 0, 0, 9)
  sb:addSpriteFrame(13, 3, 0, 0, 9)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(12, 1, 0, 0, 9)
  sb:addSpriteFrame(12, 2, 0, 0, 9)
  sb:addSpriteFrame(12, 3, 0, 0, 9)
  sb:buildSubstrip('right')
  -- BUILD jump
  builder:addAnimation('jump', sb:build())
  
  -- @animation sword_swing
  sb:setSubstrips(true)
  sb:setLoopType('once')
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
  builder:addAnimation('swing', sb:build())
  
  -- register sprite builder
  spriteBank.registerSpriteRendererBuilder('player', builder)
end

-- player sprites
---@param spriteBank SpriteBank
return makeModuleFunction(function(spriteBank)
  local sb = spriteBank.createSpriteRendererBuilder()
  local ab = spriteBank.createSpriteAnimationBuilder()

  sb:setDefaultAnimation('idle')
  sb:setFollowZ(true)

  -- animation builder setup
  ab:setSpriteSheet('player')
  ab:setDefaultLoopType('cycle')
  ab:setSubstrips(true)
  
  -- @animation idle
  -- #substrip up
  ab:addSpriteFrame(3, 1)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 1)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 1)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 1)
  ab:buildSubstrip('right')
  -- BUILD idle
  sb:addAnimation('idle', ab:build())

  -- @animation walk
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(4, 1)
  ab:addSpriteFrame(3, 1)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(8, 1)
  ab:addSpriteFrame(7, 1)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(6, 1)
  ab:addSpriteFrame(5, 1)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(2, 1)
  ab:addSpriteFrame(1, 1)
  ab:buildSubstrip('right')
  -- BUILD walk
  sb:addAnimation('walk', ab:build())

  -- @animation jump
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(4, 12, 0, 0, 9)
  ab:addSpriteFrame(5, 12, 0, 0, 9)
  ab:addSpriteFrame(6, 12, 0, 0, 9)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(4, 13, 0, 0, 9)
  ab:addSpriteFrame(5, 13, 0, 0, 9)
  ab:addSpriteFrame(6, 13, 0, 0, 9)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(1, 13, 0, 0, 9)
  ab:addSpriteFrame(2, 13, 0, 0, 9)
  ab:addSpriteFrame(3, 13, 0, 0, 9)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 12, 0, 0, 9)
  ab:addSpriteFrame(2, 12, 0, 0, 9)
  ab:addSpriteFrame(3, 12, 0, 0, 9)
  ab:buildSubstrip('right')
  -- BUILD jump
  sb:addAnimation('jump', ab:build())

  -- @animation sword_swing
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(4, 9, 0, 0, 3)
  ab:addSpriteFrame(3, 5, 0, 0, 3)
  ab:addSpriteFrame(3, 5, 0, -4, 8)
  ab:addSpriteFrame(3, 5, 0, 0, 3)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(2, 9, 0, 0, 3)
  ab:addSpriteFrame(7, 5, 0, 0, 3)
  ab:addSpriteFrame(7, 5, 0, 4, 8)
  ab:addSpriteFrame(7, 5, 0, 0, 3)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(3, 9, 0, 0, 3)
  ab:addSpriteFrame(5, 5, 0, 0, 3)
  ab:addSpriteFrame(5, 5, -4, 0, 8)
  ab:addSpriteFrame(5, 5, 0, 0, 3)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(5, 9, 0, 0, 3)
  ab:addSpriteFrame(1, 5, 0, 0, 3)
  ab:addSpriteFrame(1, 5, 4, 0, 8)
  ab:addSpriteFrame(1, 5, 0, 0, 3)
  ab:buildSubstrip('right')
  -- BUILD sword_swing
  sb:addAnimation('swing', ab:build())

  -- @animation push
  ab:setSubstrips(true)
  ab:setLoopType('cycle')
  -- #substrip up
  ab:addSpriteFrame(3, 7)
  ab:addSpriteFrame(4, 7)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 7)
  ab:addSpriteFrame(8, 7)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 7)
  ab:addSpriteFrame(6, 7)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 7)
  ab:addSpriteFrame(2, 7)
  ab:buildSubstrip('right')
  -- BUILD push
  sb:addAnimation('push', ab:build())

  -- register sprite builder
  spriteBank.registerSpriteRendererBuilder('player', sb)
end)

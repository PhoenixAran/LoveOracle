-- player sprites
---@param spriteBank SpriteBank
return makeModuleFunction(function(spriteBank)
  local sb = spriteBank.createSpriteRendererBuilder()
  local ab = spriteBank.createSpriteAnimationBuilder()


  -- builder setup
  sb:setDefaultAnimation('idle')
  sb:setFollowZ(true)

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
  ab:addSpriteFrame(1, 1)
  ab:addSpriteFrame(2, 1)
  ab:buildSubstrip('right')
  -- BUILD walk
  sb:addAnimation('walk', ab:build())

  --@animation idle_shield
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(3, 2)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 2)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 2)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 2)
  ab:buildSubstrip('right')
  -- BUILD idle_shield
  sb:addAnimation('idle_shield', ab:build())

  --@animation walk_shield
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(3, 2)
  ab:addSpriteFrame(4, 2)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 2)
  ab:addSpriteFrame(8, 2)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 2)
  ab:addSpriteFrame(6, 2)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 2)
  ab:addSpriteFrame(2, 2)
  ab:buildSubstrip('right')
  -- BUILD idle_shield
  sb:addAnimation('walk_shield', ab:build())

  -- @animation idle_shield_block
  ab:setSubstrips(true)
  ab:setLoopType('cycle')
  -- #substrip up
  ab:addSpriteFrame(3, 3)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 3)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 3)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 3)
  ab:buildSubstrip('right')
  -- BUILD idle_shield
  sb:addAnimation('idle_shield_block', ab:build())

  -- @animation walk_shield_block
  ab:setSubstrips(true)
  ab:setLoopType('cycle')
  -- #substrip up
  ab:addSpriteFrame(4, 3)
  ab:addSpriteFrame(3, 3)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(8, 3)
  ab:addSpriteFrame(7, 3)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(6, 3)
  ab:addSpriteFrame(5, 3)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(2, 3)
  ab:addSpriteFrame(1, 3)
  ab:buildSubstrip('right')
  -- BUILD idle_shield
  sb:addAnimation('walk_shield_block', ab:build())

  -- @animation idle_carry
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(3, 6)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 6)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 6)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 6)
  ab:buildSubstrip('right')
  -- BUILD idle_carry
  sb:addAnimation('idle_carry', ab:build())

  -- @animation walk_carry
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(4, 6)
  ab:addSpriteFrame(3, 6)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(8, 6)
  ab:addSpriteFrame(7, 6)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(6, 6)
  ab:addSpriteFrame(5, 6)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(2, 6)
  ab:addSpriteFrame(1, 6)
  ab:buildSubstrip('right')
  -- BUILD walk_carry
  sb:addAnimation('walk_carry', ab:build())

  -- @animation swim
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(4, 14)
  ab:addSpriteFrame(3, 14)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(8, 14)
  ab:addSpriteFrame(7, 14)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(6, 14)
  ab:addSpriteFrame(5, 14)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(2, 14)
  ab:addSpriteFrame(1, 14)
  ab:buildSubstrip('right')
  -- BUILD swim
  sb:addAnimation('swim', ab:build())

  -- @animation submerged
  ab:setSubstrips(false)
  ab:addSpriteFrame(1, 22, 0, 0, 16)
  ab:addSpriteFrame(2, 22, 0, 0, 16)
  -- BUILD submerged
  sb:addAnimation('submerged', ab:build())

  -- @animation pull
  ab:setSubstrips(true)
  ab:setLoopType('cycle')
  -- #substrip up
  ab:addSpriteFrame(4, 8)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(8, 8)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(6, 8)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(2, 8)
  ab:buildSubstrip('right')
  -- BUILD grab
  sb:addAnimation('pull', ab:build())

  -- @animation grab
  ab:setSubstrips(true)
  ab:setLoopType('cycle')
  -- #substrip up
  ab:addSpriteFrame(3, 8)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 8)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 8)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 8)
  ab:buildSubstrip('right')
  -- BUILD pull
  sb:addAnimation('grab', ab:build())

  -- @animation push
  ab:setSubstrips(true)
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

  -- @animation dig
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 10, 0, 0, 8)
  ab:addSpriteFrame(4, 10, 0, 0, 16)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 10, 0, 0, 8)
  ab:addSpriteFrame(8, 10, 0, 0, 16)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 10, 0, 0, 8)
  ab:addSpriteFrame(6, 10, 0, 0, 16)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 10, 0, 0, 8)
  ab:addSpriteFrame(2, 10, 0, 0, 16)
  ab:buildSubstrip('right')
  -- BUILD dig
  sb:addAnimation('dig', ab:build())

  -- @animation jump
  ab:setSubstrips(true)
  ab:setLoopType('cycle')
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

  -- register sprite builder
  spriteBank.registerSpriteRendererBuilder('player', sb)
end)

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
  ab:setLoopType('once')
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
  ab:setLoopType('cycle')
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

  --@animation idle_shield
  ab:setSubstrips(true)
  ab:setLoopType('once')
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
  ab:setLoopType('cycle')
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
  ab:setLoopType('once')
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
  -- BUILD walk_shield_block
  sb:addAnimation('walk_shield_block', ab:build())

  -- @animation idle_shield_block
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 3)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(3, 4)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 3)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 3)
  ab:buildSubstrip('right')
  -- BUILD idle_shield_large_block
  sb:addAnimation('idle_shield_large_block', ab:build())

  -- @animation walk_shield_block
  ab:setSubstrips(true)
  ab:setLoopType('cycle')
  -- #substrip up
  ab:addSpriteFrame(4, 3)
  ab:addSpriteFrame(3, 3)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(4, 4)
  ab:addSpriteFrame(3, 4)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(6, 3)
  ab:addSpriteFrame(5, 3)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(2, 4)
  ab:addSpriteFrame(1, 4)
  ab:buildSubstrip('right')
  -- BUILD walk_shield_large_block
  sb:addAnimation('walk_shield_large_block', ab:build())


  -- @animation idle_carry
  ab:setSubstrips(true)
  ab:setLoopType('once')
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
  ab:setLoopType('cycle')
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
  ab:setLoopType('cycle')
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
  ab:setLoopType('cycle')
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

  -- @animation throw
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 1, 0, 0, 1)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 1, 0, 0, 1)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 1, 0, 0, 1)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 1, 0, 0, 1)
  ab:buildSubstrip('right')
  -- BUILD throw
  sb:addAnimation('throw', ab:build())

  -- @animation fall
  ab:setSubstrips(false)
  ab:setLoopType('once')
  ab:addSpriteFrame(2, 21, 0, 0, 16)
  ab:addSpriteFrame(3, 21, 0, 0, 16)
  ab:addSpriteFrame(4, 21, 0, 0, 16)
  -- BUILD fall
  sb:addAnimation('fall', ab:build())

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

  -- @animation cape
  ab:setSubstrips(true)
  ab:setLoopType('cycle')
  -- #substrip up
  ab:addSpriteFrame(3, 11)
  ab:addSpriteFrame(4, 11)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 11)
  ab:addSpriteFrame(8, 11)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 11)
  ab:addSpriteFrame(6, 11)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 11)
  ab:addSpriteFrame(2, 11)
  ab:buildSubstrip('right')
  -- BUILD cape
  sb:addAnimation('cape', ab:build())

  -- @animation swing
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
  -- BUILD swing
  sb:addAnimation('swing', ab:build())

  --@animation swing_no_lunge
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(4, 9, 0, 0, 3)
  ab:addSpriteFrame(3, 5, 0, 0, 3)
  ab:addSpriteFrame(3, 5, 0, 0, 8)
  ab:addSpriteFrame(3, 5, 0, 0, 3)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(2, 9, 0, 0, 3)
  ab:addSpriteFrame(7, 5, 0, 0, 3)
  ab:addSpriteFrame(7, 5, 0, 0, 8)
  ab:addSpriteFrame(7, 5, 0, 0, 3)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(3, 9, 0, 0, 3)
  ab:addSpriteFrame(5, 5, 0, 0, 3)
  ab:addSpriteFrame(5, 5, 0, 0, 8)
  ab:addSpriteFrame(5, 5, 0, 0, 3)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(5, 9, 0, 0, 3)
  ab:addSpriteFrame(1, 5, 0, 0, 3)
  ab:addSpriteFrame(1, 5, 0, 0, 8)
  ab:addSpriteFrame(1, 5, 0, 0, 3)
  ab:buildSubstrip('right')
  -- BUILD swing_no_lunge
  sb:addAnimation('swing_no_lunge', ab:build())

  -- @animation spin
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 5, 0, -3, 5)
  ab:addSpriteFrame(1, 5, 3, 0, 3)
  ab:addSpriteFrame(7, 5, 0, 3, 5)
  ab:addSpriteFrame(5, 5, -3, 0, 5)
  ab:addSpriteFrame(3, 5, 0, -3, 3)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 5, 0, 3, 5)
  ab:addSpriteFrame(5, 5, -3, 0, 5)
  ab:addSpriteFrame(3, 5, 0, -3, 5)
  ab:addSpriteFrame(1, 5, 3, 0, 3)
  ab:addSpriteFrame(7, 5, 0, 3, 5)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 5, -3, 0, 5)
  ab:addSpriteFrame(3, 5, 0, -3, 5)
  ab:addSpriteFrame(1, 5, 3, 0, 3)
  ab:addSpriteFrame(7, 5, 0, 3, 5)
  ab:addSpriteFrame(5, 5, -3, 0, 5)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 5, 3, 0, 5)
  ab:addSpriteFrame(7, 5, 0, 3, 5)
  ab:addSpriteFrame(5, 5, -3, 0, 5)
  ab:addSpriteFrame(3, 5, 0, -3, 5)
  ab:addSpriteFrame(1, 5, 3, 0, 3)
  ab:buildSubstrip('right')
  -- BUILD spin
  sb:addAnimation('spin', ab:build())

  --@animation stab
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(7, 5, 0, 4, 6)
  ab:addSpriteFrame(7, 5, 0, 0, 7)
  ab:addSpriteFrame(8, 1, 0, 0, 1)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(3, 5, 0, -4, 6)
  ab:addSpriteFrame(3, 5, 0, 0, 7)
  ab:addSpriteFrame(4, 1, 0, 0, 1)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 5, -4, 0, 6)
  ab:addSpriteFrame(5, 5, 0, 0, 7)
  ab:addSpriteFrame(6, 1, 0, 0, 1)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 5, -4, 0, 6)
  ab:addSpriteFrame(1, 5, 0, 0, 7)
  ab:addSpriteFrame(2, 1, 0, 0, 1)
  ab:buildSubstrip('right')
  -- BUILD stab
  sb:addAnimation('stab', ab:build())

  -- @animation raise_one_hand
  ab:setSubstrips(false)
  ab:setLoopType('once')
  ab:addSpriteFrame(1, 17)
  -- BUILD raise_one_hand
  sb:addAnimation('raise_one_hand', ab:build())

  -- @animation raise_two_hands
  ab:setSubstrips(false)
  ab:setLoopType('once')
  ab:addSpriteFrame(2, 17)
  -- BUILD raise_two_hands
  sb:addAnimation('raise_two_hands', ab:build())

  -- @animation drown
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 14, 0, 2, 8)
  ab:addSpriteFrame(1, 22, 0, 4, 17)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 14, 0, 2, 8)
  ab:addSpriteFrame(1, 22, 0, 4, 17)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 14, 0, 2, 8)
  ab:addSpriteFrame(1, 22, 0, 4, 17)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 14, 0, 2, 8)
  ab:addSpriteFrame(1, 22, 0, 4, 17)
  ab:buildSubstrip('right')
  -- BUILD drown
  sb:addAnimation('drown', ab:build())

  -- @animation crush_horizontal
  ab:setSubstrips(false)
  ab:setLoopType('once')
  ab:addCompositeSprite(6, 21, 0, 0)
  ab:addCompositeSprite(7, 21, 0, -16)
  ab:addCompositeFrame(0, 0, 0, 0, 44)
  ab:repeatBuild(5, function()
    ab:addSpriteFrame(7, 1, 0, 0, 2, 0.5)
    ab:addCompositeSprite(6, 21, 0, 0)
    ab:addCompositeSprite(7, 21, 0, -16)
    ab:addCompositeFrame(0, 0, 0, 0, 2, 0.5)
    ab:addCompositeSprite(6, 21, 0, 0)
    ab:addCompositeSprite(7, 21, 0, -16)
    ab:addCompositeFrame(0, 0, 0, 0, 2, 0.5)
  end)
  -- BUILD crush_horizontal
  sb:addAnimation('crush_horizontal', ab:build())

  -- @animation crush_vertical
  ab:setSubstrips(false)
  ab:setLoopType('once')
  ab:addSpriteFrame(5, 21, 0, 0, 44)
  -- repeat
  ab:repeatBuild(5, function()
    ab:addEmptyFrame(1)
    ab:addSpriteFrame(7, 1, 0, 0, 1)
    ab:addEmptyFrame(1)
    ab:addSpriteFrame(5, 21, 0, 0, 1)
    ab:addEmptyFrame(1)
    ab:addSpriteFrame(5, 21, 0, 0, 1)
    ab:addEmptyFrame(1)
    ab:addSpriteFrame(7, 1, 0, 0, 1)
  end)
  -- BUILD crush_vertical
  sb:addAnimation('crush_vertical', ab:build())

  -- @animation invisible
  ab:setSubstrips(false)
  ab:setLoopType('once')
  ab:addEmptyFrame(1)
  -- BUILD invisible
  sb:addAnimation('invisible', ab:build())

  -- @animation aim
  -- TODO split this up into aim_down, aim_bottom_left, etc
  -- have to do it this way since we only have 4 substrips instead of 8
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 5, 0, 0, 1)
  ab:addSpriteFrame(3, 9, 0, 0, 1)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 5, 0, 0, 1)
  ab:addSpriteFrame(1, 9, 0, 0, 1)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 5, 0, 0, 1)
  ab:addSpriteFrame(2, 9, 0, 0, 1)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(7, 5, 0, 0, 1)
  ab:addSpriteFrame(1, 9, 0, 0, 1)
  ab:buildSubstrip('right')
  -- BUILD player_aim
  sb:addAnimation('aim', ab:build())

  -- @animation death
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 1, 0, 0, 10)
  ab:addSpriteFrame(1, 21, 0, 0, 32)
  ab:buildSubstrip('up', false)
  -- #substrip down
  ab:addSpriteFrame(6, 1, 0, 0, 10)
  ab:addSpriteFrame(1, 21, 0, 0, 32)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(4, 1, 0, 0, 10)
  ab:addSpriteFrame(1, 21, 0, 0, 32)
  ab:buildSubstrip('left', false)
  -- #substrip right
  ab:addSpriteFrame(1, 1, 0, 0, 10)
  ab:addSpriteFrame(1, 21, 0, 0, 32)
  ab:buildSubstrip('right', false)
  -- BUILD death
  sb:addAnimation('death', ab:build())

  -- register sprite builder
  spriteBank.registerSpriteRendererBuilder('player', sb)
end)


--- player sprite
---@param spriteBank SpriteBank
return function(spriteBank)
  local sb = spriteBank.createSpriteRendererBuilder()
  local ab = spriteBank.createSpriteAnimationBuilder()

  sb:setFollowZ(true)
  sb:setDefaultAnimation('move')

  ab:setSpriteSheet('player_items')
  ab:setSubstrips(false)
  ab:setLoopType('cycle')

  --@animation move
  ab:addSpriteFrame(1, 10, 0, 0, 2)
  ab:addSpriteFrame(4, 10, 0, 0, 2)
  ab:addSpriteFrame(3, 10, 0, 0, 2)
  ab:addSpriteFrame(2, 10, 0, 0, 2)

  -- BUILD move
  sb:addAnimation('move', ab:build())

  -- register builder
  spriteBank.registerSpriteRendererBuilder('player_boomerang_1', sb)

  sb = spriteBank.createSpriteRendererBuilder()
  ab = spriteBank.createSpriteAnimationBuilder()
  
  sb:setFollowZ(true)
  sb:setDefaultAnimation('move')

  ab:setSpriteSheet('player_items')
  ab:setSubstrips(false)

  --@animation move
  ab:addSpriteFrame(1 + 4, 10, 0, 0, 2)
  ab:addSpriteFrame(4 + 4, 10, 0, 0, 2)
  ab:addSpriteFrame(3 + 4, 10, 0, 0, 2)
  ab:addSpriteFrame(2 + 4, 10, 0, 0, 2)

  -- BUILD move
  sb:addAnimation('move', ab:build())

  -- register builder
  spriteBank.registerSpriteRendererBuilder('player_boomerang_2', sb)
end
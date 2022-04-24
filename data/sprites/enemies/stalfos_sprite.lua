-- stalfos sprite
return makeModuleFunction(function(spriteBank)
  local sb = spriteBank.createSpriteRendererBuilder()
  local ab = spriteBank.createSpriteAnimationBuilder()

  sb:setDefaultAnimation('move')
  sb:setFollowZ(true)

  -- sprite animation builder setup
  ab:setSpriteSheet('stalfos')
  ab:setDefaultLoopType('cycle')
  ab:setSubstrips(false)

  -- @animation move
  ab:addSpriteFrame(1, 1)
  ab:addSpriteFrame(1, 2)
  ab:addAnimation('move', ab:build())
  -- @animation jump
  ab:addSpriteFrame(1, 3)
  ab:addAnimation('jump', ab:build())

  spriteBank.registerSpriteRendererBuilder('stalfos', sb)
end)
-- stalfos sprite
return makeModuleFunction(function(spriteBank)
  ---@type SpriteRendererBuilder
  local sb = spriteBank.createSpriteRendererBuilder()
  ---@type SpriteAnimationBuilder
  local ab = spriteBank.createSpriteAnimationBuilder()

  sb:setDefaultAnimation('move')
  sb:setFollowZ(true)

  -- sprite animation builder setup
  ab:setSpriteSheet('stalfos')
  ab:setDefaultLoopType('cycle', true)
  ab:setSubstrips(false)

  -- @animation move
  ab:addSpriteFrame(1, 1)
  ab:addSpriteFrame(2, 1)
  sb:addAnimation('move', ab:build())
  -- @animation jump
  ab:addSpriteFrame(3, 1)
  sb:addAnimation('jump', ab:build())
  spriteBank.registerSpriteRendererBuilder('stalfos', sb)
end)
-- player sprites
local entityEffectsSpriteBuilder = { }

function entityEffectsSpriteBuilder.configureSpriteBuilder(builder)
  builder:setDefaultAnimation('shadow')
  builder:setFollowZ(false)
  local sb = builder:createSpriteAnimationBuilder()
  
  sb:setSpriteSheet('effects')
  sb:setDefaultLoopType('cycle')

  -- @animation shadow
  sb:addSpriteFrame(1, 1)
  builder:addAnimation('shadow', sb:build())
end

function entityEffectsSpriteBuilder.getKey()
  return 'entity_effects'
end

return entityEffectsSpriteBuilder
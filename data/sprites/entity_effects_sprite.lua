return makeModuleFunction(
  ---@param spriteBank SpriteBank
  function(spriteBank)
    local builder = spriteBank.createSpriteRendererBuilder()
    local sb = spriteBank.createSpriteAnimationBuilder()
    builder:setDefaultAnimation('shadow')
    builder:setFollowZ(false)
    
    sb:setSpriteSheet('effects')
    sb:setDefaultLoopType('cycle')

    -- @animation shadow
    sb:addSpriteFrame(1, 1)
    builder:addAnimation('shadow', sb:build())

    --@animation puddle ripple
    sb:addSpriteFrame(5, 3, -5, -5, 8)

    --v@animation grass movement


    -- register builder
    spriteBank.registerSpriteRendererBuilder('entity_effects', builder)
  end)
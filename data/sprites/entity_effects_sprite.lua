return makeModuleFunction(
  ---@param spriteBank SpriteBank
  function(spriteBank)
    local builder = spriteBank.createSpriteRendererBuilder()
    local sb = spriteBank.createSpriteAnimationBuilder()

    -- builder setup
    builder:setDefaultAnimation('shadow')
    builder:setFollowZ(false)

    sb:setSpriteSheet('effects')
    sb:setDefaultLoopType('cycle')

    -- @animation shadow
    sb:addSpriteFrame(1, 1)
    builder:addAnimation('shadow', sb:build())

    -- @animation ripples
    sb:addCompositeSprite(5, 3, -5 + 8, -5)
    sb:addCompositeSprite(6, 3, -11 + 8, -5)
    sb:addCompositeFrame(0, 0, 0, 0, 8)

    sb:addCompositeSprite(5, 3, -6 + 8, -5)
    sb:addCompositeSprite(6, 3, -10 + 8, -5)
    sb:addCompositeFrame(0, 0, 0, 0, 8)

    sb:addCompositeSprite(5, 3, -7 + 8, -4)
    sb:addCompositeSprite(6, 3, -9 + 8, -4)
    sb:addCompositeFrame(0, 0, 0, 0, 8)

    sb:addCompositeSprite(5, 3, -8 + 8, -3)
    sb:addCompositeSprite(6, 3, -8 + 8, -3)
    sb:addCompositeFrame(0, 0, 0, 0, 8)
    -- BUILD rippples
    builder:addAnimation('ripple', sb:build())
    
    
    --@animation grass movement
    sb:addCompositeSprite(7, 1, -4, 1)
    sb:addCompositeSprite(7, 1, 4, 1)
    sb:addCompositeFrame(0, 0, 0, 0, 4)

    sb:addCompositeSprite(8, 1, 4, 1)
    sb:addCompositeSprite(8, 1, -4, 1)
    sb:addCompositeFrame(0, 0, 0, 0, 4)
    -- BUILD grass
    builder:addAnimation('grass', sb:build())

    -- register builder
    spriteBank.registerSpriteRendererBuilder('entity_effects', builder)
  end)
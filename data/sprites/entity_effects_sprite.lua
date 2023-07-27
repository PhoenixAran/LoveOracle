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
    sb:addCompositeSprite(5, 3, -5, -5)
    sb:addCompositeSprite(6, 3, -11, -5)
    sb:addCompositeFrame(0, 0, 0, 0, 8)

    sb:addCompositeSprite(5, 3, -6, -5)
    sb:addCompositeSprite(6, 3, -10, -5)
    sb:addCompositeFrame(0, 0, 0, 0, 8)

    sb:addCompositeSprite(5, 3, -7, -4)
    sb:addCompositeSprite(6, 3, -9, -4)
    sb:addCompositeFrame(0, 0, 0, 0, 8)

    sb:addCompositeSprite(5, 3, -8, -3)
    sb:addCompositeSprite(6, 3, -8, -3)
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

    --@animation red grass movement

    -- register builder
    spriteBank.registerSpriteRendererBuilder('entity_effects', builder)
  end)
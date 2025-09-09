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

    -- @effect animation ripples
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
    -- BUILD ripples
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


    -- @animation effect_dirt
    sb:setSubstrips(true)
    sb:setLoopType('once')
    -- #substrip right
    sb:addCompositeSprite(6, 1, -12 + 8, -9)
    sb:addCompositeSprite(6, 1, -8 + 8, -3)
    sb:addCompositeFrame(0, 0, 0, 0, 1)
    sb:buildSubstrip('right')
    -- #substrip up
    sb:addCompositeSprite(5, 1, -8 + 8, -8)
    sb:addCompositeSprite(6, 1, -8 + 8, -6)
    sb:addCompositeFrame(0, 0, 0, 0, 1)
    sb:buildSubstrip('up', true)
    -- #substrip left
    sb:addCompositeSprite(5, 1, -2 + 8, -9)
    sb:addCompositeSprite(5, 1, 0 + 8, -2)
    sb:addCompositeFrame(0, 0, 0, 0, 1)
    sb:buildSubstrip('left')
    -- #substrip down
    sb:addCompositeSprite(5, 1, -8 + 8, -6)
    sb:addCompositeSprite(6, 1, -8 + 8, -8)
    sb:addCompositeFrame(0, 0, 0, 0, 1)
    sb:buildSubstrip('down')
    -- BUILD dirt
    builder:addAnimation('effect_dirt', sb:build())

    -- todo EFFECT MAGNET GLOVES ?


    -- register builder
    spriteBank.registerSpriteRendererBuilder('entity_effects', builder)
  end)
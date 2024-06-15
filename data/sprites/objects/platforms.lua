--- platform sprites
---@param spriteBank SpriteBank
return function(spriteBank)
    local sb = spriteBank.createSpriteBuilder()
    local srb = spriteBank.createSpriteRendererBuilder()
    srb.type = 'sprite_renderer' -- platforms just use static sprites

    --1x1 platform
    srb:setSprite(sb:buildSpriteFromImage('1x1_platform'))
    spriteBank.registerSpriteRendererBuilder('1x1_platform', srb)

    --1x2 platform
    srb = spriteBank.createSpriteRendererBuilder()
    srb.type = 'sprite_renderer' -- platforms just use static sprites
    srb:setSprite(sb:buildSpriteFromImage('1x2_platform'))
    spriteBank.registerSpriteRendererBuilder('1x2_platform', srb)

    --2x1 platform
    srb = spriteBank.createSpriteRendererBuilder()
    srb.type = 'sprite_renderer' -- platforms just use static sprites
    srb:setSprite(sb:buildSpriteFromImage('2x2_platform'))
    spriteBank.registerSpriteRendererBuilder('2x2_platform', srb)

    --2x2 platform
    srb = spriteBank.createSpriteRendererBuilder()
    srb.type = 'sprite_renderer' -- platforms just use static sprites
    srb:setSprite(sb:buildSpriteFromImage('2x2_platform'))
    spriteBank.registerSpriteRendererBuilder('2x2_platform', srb)
end
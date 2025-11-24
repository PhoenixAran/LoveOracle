return makeModuleFunction(function(spriteBank)
  ---@type SpriteRendererBuilder
  local sb = spriteBank.createSpriteRendererBuilder()
  ---@type SpriteAnimationBuilder
  local ab = spriteBank.createSpriteAnimationBuilder()
  ab:setSpriteSheet('monster_items')


  -- monster spear
  sb:setDefaultAnimation('move')
  sb:setFollowZ(true)
  ab:setSubstrips(true)
  
  -- @animation move
  -- #substrip up
  ab:addSpriteFrame(2, 1)
  ab:buildSubstrip('up')

  -- #substrip down
  ab:addSpriteFrame(4, 1)
  ab:buildSubstrip('down', true)

  -- substrip left
  ab:addSpriteFrame(3, 1)
  ab:buildSubstrip('left')

  -- #substrip right
  ab:addSpriteFrame(1, 1)
  ab:buildSubstrip('right')
  
  --@BUILD move
  sb:addAnimation('move', ab:build())

  -- REGISTER monster_spear
  spriteBank.registerSpriteRendererBuilder('monster_spear', sb)


  -- monster arrows
  sb = spriteBank.createSpriteRendererBuilder()
  sb:setDefaultAnimation('move')
  sb:setFollowZ(true)
  ab:setSubstrips(true)

  -- sprite animation builder setup
  ab:setSpriteSheet('monster_items')
  ab:setDefaultLoopType('cycle', true)
  ab:setSubstrips(true)

  -- @animation move
  -- #substrip up
  ab:addSpriteFrame(2, 2)
  ab:buildSubstrip('up')

  -- #substrip down
  ab:addSpriteFrame(4, 2)
  ab:buildSubstrip('down', true)

  -- #substrip  left
  ab:addSpriteFrame(3, 2)
  ab:buildSubstrip('left')

  -- #substrip right
  ab:addSpriteFrame(1, 2)
  ab:buildSubstrip('right')

  -- BUILD move
  sb:addAnimation('move', ab:build())

  -- @animation crash
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(2, 2, -8, -8, 6)
  ab:addSpriteFrame(3, 2, -8, -8, 6)
  ab:addSpriteFrame(4, 2, -8, -8, 6)
  ab:addSpriteFrame(1, 2, -8, -8, 6)
  ab:buildSubstrip('up')

  -- #substrip down
  ab:addSpriteFrame(4, 2, -8, -8, 6)
  ab:addSpriteFrame(1, 2, -8, -8, 6)
  ab:addSpriteFrame(2, 2, -8, -8, 6)
  ab:addSpriteFrame(3, 2, -8, -8, 6)
  ab:buildSubstrip('down', true)

  -- #substrip left
  ab:addSpriteFrame(3, 2, -8, -8, 6)
  ab:addSpriteFrame(4, 2, -8, -8, 6)
  ab:addSpriteFrame(1, 2, -8, -8, 6)
  ab:addSpriteFrame(2, 2, -8, -8, 6)
  ab:buildSubstrip('left')

  -- #substrip right
  ab:addSpriteFrame(1, 2, -8, -8, 6)
  ab:addSpriteFrame(2, 2, -8, -8, 6)
  ab:addSpriteFrame(3, 2, -8, -8, 6)
  ab:addSpriteFrame(4, 2, -8, -8, 6)
  ab:buildSubstrip('right')

  -- BUILD crash
  sb:addAnimation('crash', ab:build())

  -- REGISTER monster_arrow
  spriteBank.registerSpriteRendererBuilder('monster_arrow', sb)


  -- projectile_monster_beam
  sb = spriteBank.createSpriteRendererBuilder()
  sb:setDefaultAnimation('move')
  sb:setFollowZ(true)
  ab:setSubstrips(false)

  -- TODO offset -8 -8s?
  ab:addSpriteFrame(1, 4, 0, 0, 1)
  ab:addSpriteFrame(2, 4, 0, 0, 1)
  ab:addSpriteFrame(3, 4, 0, 0, 1)
  ab:addSpriteFrame(4, 4, 0, 0, 1)
  ab:addSpriteFrame(1, 4, 0, 0, 1)
  ab:addSpriteFrame(2, 4, 0, 0, 1)
  ab:addSpriteFrame(3, 4, 0, 0, 1)
  ab:addSpriteFrame(4, 4, 0, 0, 1)

  -- BUILD move
  sb:addAnimation('move', ab:build())

  -- REGISTER projectile_monster_beam
  spriteBank.registerSpriteRendererBuilder('projectile_monster_beam', sb)
  

  
  -- projectile_monster_boomerang
  sb = spriteBank.createSpriteRendererBuilder()
  sb:setDefaultAnimation('move')
  sb:setFollowZ(true)
  ab:setSubstrips(false)

  --@animation move
  -- TODO offset -8 -8s?
  ab:addSpriteFrame(5, 1, 0, 0, 2)
  ab:addSpriteFrame(6, 1, 0, 0, 2)
  ab:addSpriteFrame(7, 1, 0, 0, 2)
  ab:addSpriteFrame(8, 1, 0, 0, 2)

  -- BUILD move
  sb:addAnimation('move', ab:build())
  spriteBank.registerSpriteRendererBuilder('projectile_monster_boomerang', sb)


  -- projectile_monster_magic
  sb = spriteBank.createSpriteRendererBuilder()
  sb:setDefaultAnimation('move')
  sb:setFollowZ(true)
  ab:setSubstrips(true)

  -- #substrip up
  ab:addSpriteFrame(6, 2, 0, 0)
  ab:buildSubstrip('up')

  -- #substrip down
  ab:addSpriteFrame(8, 2, 0, 0)
  ab:buildSubstrip('down', true)

  -- #substrip left
  ab:addSpriteFrame(7, 2, 0, 0)
  ab:buildSubstrip('left')

  --#substrip right
  ab:addSpriteFrame(5, 2, 0, 0)
  ab:buildSubstrip('right')

  -- BUILD move
  sb:addAnimation('move', ab:build())

  -- register builder
  spriteBank.registerSpriteRendererBuilder('projectile_monster_magic', sb)

  -- projectile_monster_fireball
  sb = spriteBank.createSpriteRendererBuilder()
  sb:setDefaultAnimation('move')
  sb:setFollowZ(true)
  ab:setSubstrips(false)

  -- TODO -8, -8 offsets?
  ab:addSpriteFrame(5, 4, 0, 0, 4)
  ab:addSpriteFrame(6, 4, 0, 0, 4)

  -- BUILD move
  sb:addAnimation('move', ab:build())

  -- register builder
  spriteBank.registerSpriteRendererBuilder('projectile_monster_fireball', sb)


  -- projectile_monster_bone
  sb = spriteBank.createSpriteRendererBuilder()
  sb:setDefaultAnimation('move')
  ab:setSubstrips(false)

  -- BUILD move
  -- TODO -8, -8 offsets?
  ab:addSpriteFrame(5, 3, 0, 0, 4)
  ab:addSpriteFrame(6, 3, 0, 0, 4)

  -- BUILD move
  sb:addAnimation('move', ab:build())

  -- register builder
  spriteBank.registerSpriteRendererBuilder('projectile_monster_bone', sb)

  -- projectile_monster_rock
  sb = spriteBank.createSpriteRendererBuilder()
  sb:setDefaultAnimation('move')
  ab:setSubstrips(false)

  -- BUILD move
  -- TODO -8, -8 offsets?
  ab:addSpriteFrame(7, 3, 0, 0)
  -- BUILD move
  sb:addAnimation('move', ab:build())

  -- register builder
  spriteBank.registerSpriteRendererBuilder('projectile_monster_rock', sb)
end)
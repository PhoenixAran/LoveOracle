return function(spriteBank)
  local builder = spriteBank.createSpriteRendererBuilder()
  local sb = spriteBank.createSpriteAnimationBuilder()
  
  builder:setFollowZ(true)
  builder:setDefaultAnimation('swing')
  
  -- sprite animation builder setup
  sb:setSpriteSheet('player_items')
  -- TODO animate Hitboxes!!
  
  -- @animation swing
  sb:setSubstrips(true)
  -- #substrip up
  sb:addSpriteFrame(1, 1, 16, 0, 3)
  sb:addSpriteFrame(1, 2, 13, -13, 3)
  sb:addSpriteFrame(1, 3, -4, -20, 8)
  sb:addSpriteFrame(1, 3, -4, -12, 3)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(1, 5, -15, 2, 3)
  sb:addSpriteFrame(1, 6, -13, 15, 3)
  sb:addSpriteFrame(1, 7, 3, 20, 8)
  sb:addSpriteFrame(1, 7, 3, 14, 3)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(1, 3, 0, -16, 3)
  sb:addSpriteFrame(1, 4, -13, -13, 3)
  sb:addSpriteFrame(1, 5, -20, 4, 8)
  sb:addSpriteFrame(1, 5, -12, 4, 3)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(1, 3, 0, -16, 3)
  sb:addSpriteFrame(1, 2, 13, -13, 3)
  sb:addSpriteFrame(1, 1, 20, 4, 8)
  sb:addSpriteFrame(1, 1, 12, 4, 3)
  sb:buildSubstrip('right')
  -- BUILD sword_swing
  builder:addAnimation('swing', sb:build())
  
  -- register builder
  spriteBank.registerSpriteRendererBuilder('player_sword', builder)
end

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
  sb:addSpriteFrame(2, 1, 13, -13, 3)
  sb:addSpriteFrame(3, 1, -4, -20, 8)
  sb:addSpriteFrame(3, 1, -4, -12, 3)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(5, 1, -15, 2, 3)
  sb:addSpriteFrame(6, 1, -13, 15, 3)
  sb:addSpriteFrame(7, 1, 3, 20, 8)
  sb:addSpriteFrame(8, 2, 3, 14, 3)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(3, 1, 0, -16, 3)
  sb:addSpriteFrame(4, 1, -13, -13, 3)
  sb:addSpriteFrame(5, 1, -20, 4, 8)
  sb:addSpriteFrame(5, 1, -12, 4, 3)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(3, 1, 0, -16, 3)
  sb:addSpriteFrame(2, 1, 13, -13, 3)
  sb:addSpriteFrame(1, 1, 20, 4, 8)
  sb:addSpriteFrame(1, 1, 12, 4, 3)
  sb:buildSubstrip('right')
  -- BUILD sword_swing
  builder:addAnimation('swing', sb:build())
  
  -- register builder
  spriteBank.registerSpriteRendererBuilder('player_sword', builder)
end

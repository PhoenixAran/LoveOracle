-- player sprites
return function(spriteBank)
  local builder = spriteBank.createSpriteRendererBuilder()
  local sb = spriteBank.createSpriteAnimationBuilder()

  builder:setDefaultAnimation('idle')
  builder:setFollowZ(true)

  -- sprite animation builder setup
  sb:setSpriteSheet('player')
  sb:setDefaultLoopType('cycle')

  -- @animation idle
  sb:setSubstrips(true)
  -- #substrip up
  sb:addSpriteFrame(3, 1)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(7, 1)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(5, 1)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(1, 1)
  sb:buildSubstrip('right')
  -- BUILD idle
  builder:addAnimation('idle', sb:build())

  -- @animation walk
  sb:setSubstrips(true)
  -- #substrip up
  sb:addSpriteFrame(4, 1)
  sb:addSpriteFrame(3, 1)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(8, 1)
  sb:addSpriteFrame(7, 1)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(6, 1)
  sb:addSpriteFrame(5, 1)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(2, 1)
  sb:addSpriteFrame(1, 1)
  sb:buildSubstrip('right')
  -- BUILD walk
  builder:addAnimation('walk', sb:build())

  -- @animation jump
  sb:setSubstrips(true)
  -- #substrip up
  sb:addSpriteFrame(4, 12, 0, 0, 9)
  sb:addSpriteFrame(5, 12, 0, 0, 9)
  sb:addSpriteFrame(6, 12, 0, 0, 9)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(4, 13, 0, 0, 9)
  sb:addSpriteFrame(5, 13, 0, 0, 9)
  sb:addSpriteFrame(6, 13, 0, 0, 9)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(1, 13, 0, 0, 9)
  sb:addSpriteFrame(2, 13, 0, 0, 9)
  sb:addSpriteFrame(3, 13, 0, 0, 9)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(1, 12, 0, 0, 9)
  sb:addSpriteFrame(2, 12, 0, 0, 9)
  sb:addSpriteFrame(3, 12, 0, 0, 9)
  sb:buildSubstrip('right')
  -- BUILD jump
  builder:addAnimation('jump', sb:build())

  -- @animation sword_swing
  sb:setSubstrips(true)
  sb:setLoopType('once')
  -- #substrip up
  sb:addSpriteFrame(4, 9, 0, 0, 3)
  sb:addSpriteFrame(3, 5, 0, 0, 3)
  sb:addSpriteFrame(3, 5, 0, -4, 8)
  sb:addSpriteFrame(3, 5, 0, 0, 3)
  sb:buildSubstrip('up')
  -- #substrip down
  sb:addSpriteFrame(2, 9, 0, 0, 3)
  sb:addSpriteFrame(7, 5, 0, 0, 3)
  sb:addSpriteFrame(7, 5, 0, 4, 8)
  sb:addSpriteFrame(7, 5, 0, 0, 3)
  sb:buildSubstrip('down', true)
  -- #substrip left
  sb:addSpriteFrame(3, 9, 0, 0, 3)
  sb:addSpriteFrame(5, 5, 0, 0, 3)
  sb:addSpriteFrame(5, 5, -4, 0, 8)
  sb:addSpriteFrame(5, 5, 0, 0, 3)
  sb:buildSubstrip('left')
  -- #substrip right
  sb:addSpriteFrame(5, 9, 0, 0, 3)
  sb:addSpriteFrame(1, 5, 0, 0, 3)
  sb:addSpriteFrame(1, 5, 4, 0, 8)
  sb:addSpriteFrame(1, 5, 0, 0, 3)
  sb:buildSubstrip('right')
  -- BUILD sword_swing
  builder:addAnimation('swing', sb:build())

  -- register sprite builder
  spriteBank.registerSpriteRendererBuilder('player', builder)
end

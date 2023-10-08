---player sword sprites
---@param spriteBank SpriteBank
return function(spriteBank)
  local sb = spriteBank.createSpriteRendererBuilder()
  local ab = spriteBank.createSpriteAnimationBuilder()

  local function alterHitbox(x, y, w, h)
    x = x + w / 2
    y = y + h / 2
    return function(ent)
      ent.hitbox:move(x, y, w, h)
    end
  end

  sb:setFollowZ(true)
  sb:setDefaultAnimation('swing')

  -- sprite animation builder setup
  ab:setSpriteSheet('player_items')
  -- TODO animate Hitboxes!!

  -- @animation swing
  ab:setSubstrips(true)
  -- #substrip up
  ab:addSpriteFrame(1, 1, 16, 0, 3)
  ab:addSpriteFrame(2, 1, 13, -13, 3)
  ab:addSpriteFrame(3, 1, -4, -20, 8)
  ab:addSpriteFrame(3, 1, -4, -12, 3)

  ab:addTimedAction(1, alterHitbox(8, -8, 10, 16))
  ab:addTimedAction(2, alterHitbox(-8 + 10 - 6, -8 - 10, 16 + 6, 10))
  ab:addTimedAction(3, alterHitbox(-8, -8 - 19, 10, 19))
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(5, 1, -15, 2, 3)
  ab:addSpriteFrame(6, 1, -13, 15, 3)
  ab:addSpriteFrame(7, 1, 3, 20, 8)
  ab:addSpriteFrame(8, 2, 3, 14, 3)

  ab:addTimedAction(3, alterHitbox(8 - 10, 8, 10, 19))
  ab:addTimedAction(2, alterHitbox(-8 - 10, 8, 16 + 6, 10))
  ab:addTimedAction(1, alterHitbox(-8 - 10, -8, 10, 16))
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(3, 1, 0, -16, 3)
  ab:addSpriteFrame(4, 1, -13, -13, 3)
  ab:addSpriteFrame(5, 1, -20, 4, 8)
  ab:addSpriteFrame(5, 1, -12, 4, 3)

  ab:addTimedAction(1, alterHitbox(-8, -8 - 10, 16, 10))
  ab:addTimedAction(2, alterHitbox(-8 - 10, -8 - 10, 10, 16 + 6))
  ab:addTimedAction(3, alterHitbox(-8 - 19, 8 - 10, 19, 10))
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(3, 1, 0, -16, 3)
  ab:addSpriteFrame(2, 1, 13, -13, 3)
  ab:addSpriteFrame(1, 1, 20, 4, 8)
  ab:addSpriteFrame(1, 1, 12, 4, 3)

  ab:addTimedAction(1, alterHitbox(-8, -8 - 10, 16, 10))
  ab:addTimedAction(2, alterHitbox(8, -8 - 10, 10, 16 + 6))
  ab:addTimedAction(3, alterHitbox(8, 8 - 10, 19, 10))
  ab:buildSubstrip('right')
  -- BUILD sword_swing
  sb:addAnimation('swing', ab:build())

  -- @animation hold
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 1, -4, -20, 6)
  ab:addTimedAction(1, alterHitbox(-8, -8 - 19, 10, 19))
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 1, 3, 20, 6)
  ab:addTimedAction(1, alterHitbox(8 - 10, 8, 10, 19))
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 1, -20, 4, 6)
  ab:addTimedAction(1, alterHitbox(-8 - 19, 8 - 10, 19, 10))
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 1, 20, 4, 6)
  ab:addTimedAction(1, alterHitbox(8, 8 - 10, 19, 10))
  ab:buildSubstrip('right')
  -- BUILD hold
  sb:addAnimation('hold', ab:build())

  -- @animation stab
  ab:setSubstrips(true)
  ab:setLoopType('once')
  -- #substrip up
  ab:addSpriteFrame(3, 1, -4, -20, 6)
  ab:addSpriteFrame(3, 1, -4, -12, 8)
  ab:buildSubstrip('up')
  -- #substrip down
  ab:addSpriteFrame(7, 1, 3, 20, 6)
  ab:addSpriteFrame(7, 1, 3, 14, 8)
  ab:buildSubstrip('down', true)
  -- #substrip left
  ab:addSpriteFrame(5, 1, -20, 4, 6)
  ab:addSpriteFrame(5, 1, -14, 4, 8)
  ab:buildSubstrip('left')
  -- #substrip right
  ab:addSpriteFrame(1, 1, 20, 4, 6)
  ab:addSpriteFrame(1, 1, 12, 4, 8)
  ab:buildSubstrip('right')
  -- BUILD stab
  sb:addAnimation('stab', ab:build())


  -- register builder
  spriteBank.registerSpriteRendererBuilder('player_sword', sb)
end

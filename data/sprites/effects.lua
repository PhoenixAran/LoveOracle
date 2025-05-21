---@param spriteBank SpriteBank
local function moduleFunction(spriteBank)
  local sb = spriteBank.createSpriteAnimationBuilder()
  sb:setSpriteSheet('effects')
  sb:setDefaultLoopType('once')

  --@animation splash
  sb:addCompositeSprite(3, 3, 0, -11)
  sb:addCompositeSprite(4, 3, 0, -11)
  sb:addCompositeFrame(0, 0, 0, 0, 4)

  sb:addCompositeSprite(3, 3, -2, -13)
  sb:addCompositeSprite(4, 3, 2, -13)
  sb:addCompositeFrame(0, 0, 0, 0, 4)

  sb:addCompositeSprite(3, 3, -4, -15)
  sb:addCompositeSprite(4, 3, 4, -13)
  sb:addCompositeFrame(0, 0, 0, 0, 4)

  local splashAnimation = sb:build()
  spriteBank.registerAnimation('effect_splash', splashAnimation)

  -- @animation object_fall
  
end

return moduleFunction
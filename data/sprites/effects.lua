---@param spriteBank SpriteBank
local function moduleFunction(spriteBank)
  local sb = spriteBank.createSpriteAnimationBuilder()
  sb:setSpriteSheet('effects')
  sb:setDefaultLoopType('cycle')

  --@animation splash
  sb:addCompositeSprite(3, 3, -8, -11)
  sb:addCompositeSprite(3, 4, -8, -11)
  sb:addCompositeFrame(0, 0, 0, 0, 4)

  sb:addCompositeSprite(3, 3, -10, -13)
  sb:addCompositeSprite(3, 4, -6, -13)
  sb:addCompositeFrame(0, 0, 0, 0, 4)

  sb:addCompositeSprite(3, 3, -12, -15)
  sb:addCompositeSprite(3, 4, -4, -13)
  sb:addCompositeFrame(0, 0, 0, 0, 4)

  local splashAnimation = sb:build()
  spriteBank.registerAnimation('splash', splashAnimation)
end

return moduleFunction
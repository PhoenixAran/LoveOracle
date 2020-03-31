local class = require 'lib.class'
local SpriteFrame = require 'engine.graphics.sprite_frame'
local SpriteAnimation = require 'engine.graphics.sprite_animation'

local SpriteBuilder = class {
  init = function(self)
    self.sprite = nil

    self.frames = { }
    self.quad = { }
    self.loopType = "none"
    self.offsetX = 0
    self.offsetY = 0
    self.event = nil
    self.delay = 0

    self.quadCollection = nil
    self.quadCollectionRows = 0
    self.quadCollectionCols = 0
  end
}

function SpriteBuilder:getType()
  return 'spritebuilder'
end

function SpriteBuilder:setSprite(sprite)
  self.sprite = sprite
end

function SpriteBuilder:setQuadCollection(quadCollection, row, col)
  self.quadCollection = quadCollection
  self.quadCollectionRows = row
  self.quadCollectionCols = col
end

function SpriteBuilder:setQuad(x, y)
  self.quad = self.quadCollection[(self.quadCollectionRows * x + y) + 1]
  return self
end

function SpriteBuilder:setLooptype(loopType)
  self.loopType = loopType
  return self
end

function SpriteBuilder:clearQuad()
  self.quad = nil
  return self
end

function SpriteBuilder:setOffsetX(x)
  self.x = x
  return self
end

function SpriteBuilder:setOffsetY(y)
  self.y = y
  return self
end

function SpriteBuilder:setOffset(x, y)
  return self:setOffsetX(x):setOffsetY(y)
end

function SpriteBuilder:clearOffset()
  return self:setOffset(0, 0)
end

function SpriteBuilder:setEvent(event)
  self.event = event
  return self
end

function SpriteBuilder:clearEvent()
  self.event = nil
  return self
end

function SpriteBuilder:setDelay(delay)
  self.delay = delay
  return self
end

function SpriteBuilder:clearDelay()
  return self:setDelay(0)
end

function SpriteBuilder:buildFrame(keepVars)

  if keepVars == nil then
    keepVars = false
  end

  local newFrame = SpriteFrame(self.quad, self.delay, self.offsetX, self.offsetY, self.event)

  if not keepVars then
    self:clearQuad()
        :clearDelay()
        :clearOffset()
        :clearEvent()
  end

  self.frames[#self.frames + 1] = newFrame
  return self
end

function SpriteBuilder:buildAnimation(key)
  local spriteAnimation = SpriteAnimation(self.frames, self.loopType)
  self.sprite:addAnimation(key, spriteAnimation)
  self.frames = { }
  self:clearQuad()
      :clearDelay()
      :clearOffset()
      :clearEvent()
end

return SpriteBuilder

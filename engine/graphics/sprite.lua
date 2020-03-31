local class = require 'lib.class'
local Transform = require 'lib.transform'
local Component = require 'engine.entities.component'

local Sprite = class {
  __includes = Component,
  init = function(self, image, w, h)
    Component.init(self, true, true)
    self.image = image
    self.animations = { }
    self.currentAnimation = nil
    self.cachedAnimationKey = nil
    self.width = w
    self.height = h
    self.modulating = false
    self.modulateTime = 0
    self.currentModulateTime = 0
    self.alpha = 255 / 255
  end
}

function Sprite:getType()
  return 'sprite'
end

function Sprite:addAnimation(key, animation)
  self.animations[key] = animation
end

function Sprite:isPlaying()
  if self.currentAnimation ~= nil then
    return self.currentAnimation.playing
  end
  return false
end

function Sprite:play(key)
  if key == nil then
    key = self.cachedAnimationKey
  end
  self.cachedAnimationKey = key
  self.currentAnimation = self.animations[key]
  self.currentAnimation:play()
end

function Sprite:setModulateTime(frames)
  self.modulating = true
  self.currentModulateTime = 0
  self.modulateTime = frames
  self.alpha = .35
end

--game loop API
function Sprite:update(dt)
  if self.modulating then
    if self.currentModulateTime <= self.modulateTime then
      self.currentModulateTime = self.currentModulateTime + 1
    else
      self.modulating = false
      self.currentModulateTime = 0
      self.modulateTime = 0
      self.alpha = 1
    end
  end
  self.currentAnimation:update(dt, self.entity)
end

function Sprite:draw()
  if self.currentAnimation ~= nil then
    local spriteFrame = self.currentAnimation:getCurrentSpriteFrame()
    local xPosition, yPosition = self:getPosition()
    xPosition = xPosition + spriteFrame.offsetX
    yPosition = yPosition + spriteFrame.offsetY
    love.graphics.setColor(1, 1, 1, self.alpha)
    love.graphics.draw(self.image, spriteFrame.quad, xPosition - (self.width / 2), yPosition - (self.height / 2), 0, 1)
    love.graphics.setColor(1, 1, 1, 1)
  end
end

return Sprite

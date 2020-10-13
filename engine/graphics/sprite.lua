local Class = require 'lib.class'

local Sprite = Class {
  init = function(self, subtexture, offsetX, offsetY)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end
    print(offsetX, offsetY)
    self.subtexture = subtexture
    self.offsetX = offsetX
    self.offsetY = offsetY
    local w, h = self:getDimensions()
    self.originX = w / 2
    self.originY = h / 2
  end
}

function Sprite:getType()
  return 'sprite'
end

function Sprite:getOffset()
  return self.offsetX, self.offsetY
end

function Sprite:getOffsetX()
  return self.offsetX
end

function Sprite:getOffsetY()
  return self.offsetY
end

function Sprite:getWidth()
  local w, _ = self.subtexture:getDimensions()
  return w
end

function Sprite:getHeight()
  local _, h = self.subtexture:getDimensions()
  return h
end

function Sprite:getDimensions()
  return self.subtexture:getDimensions()
end

function Sprite:getBounds()
  local x, y = self:getOffset()
  local w, h = self:getDimensions()
  return x, y, w, h
end

function Sprite:getOrigin()
  return self.originX, self.originY
end

function Sprite:draw(x, y, alpha)
  x = (x - self:getWidth() / 2) + self:getOffsetX()
  y = (y - self:getHeight() / 2) + self:getOffsetY()
  if alpha == nil then alpha = 1 end
  love.graphics.setColor(1, 1, 1, alpha)
  love.graphics.draw(self.subtexture.image, self.subtexture.quad, x, y)
  love.graphics.setColor(1, 1, 1)
end

return Sprite
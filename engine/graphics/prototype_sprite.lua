local Class = require 'lib.class'

local PrototypeSprite = Class {
  init = function(self, r, g, b, width, height, offsetX, offsetY)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end

    self.r = r
    self.g = g
    self.b = b
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.w = width
    self.h = height
    self.originX = self.w / 2
    self.originY = self.h / 2
  end
}

function PrototypeSprite:getType()
  return 'prototype_sprite'
end

function PrototypeSprite:getOffset()
  return self.offsetX, self.offsetY
end

function PrototypeSprite:getOffsetX()
  return self.offsetX
end

function PrototypeSprite:getOffsetY()
  return self.offsetY
end

function PrototypeSprite:getWidth()
  return self.w
end

function PrototypeSprite:getHeight()
  return self.h
end

function PrototypeSprite:getDimensions()
  return self.width, self.height
end

function PrototypeSprite:getBounds()
  local x, y = self:getOffset()
  local w, h = self:getDimensions()
  return x, y, w, h
end

function PrototypeSprite:getOrigin()
  return self.originX, self.originY
end

function PrototypeSprite:draw(x, y, alpha)
  x = (x - self:getWidth() / 2) + self:getOffsetX()
  y = (y - self:getHeight() / 2) + self:getOffsetY()
  if alpha == nil then alpha = 1 end
  love.graphics.setColor(self.r, self.g, self.b, alpha)
  love.graphics.rectangle('fill', x, y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

return PrototypeSprite
local Class = require 'lib.class'

-- Acts as a sprite
-- Its really just a colored rectangle
---@class PrototypeSprite
---@field r number
---@field g number
---@field b number
---@field w number width
---@field h number height
---@field originX number
---@field originY number
---@field offsetX number
---@field offsetY number
---@field alpha number?
local PrototypeSprite = Class {
  init = function(self, r, g, b, width, height, offsetX, offsetY, alpha)
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

    if alpha == nil then
      self.alpha = 1
    else
      self.alpha = alpha
    end
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
  return self.w, self.h
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
  alpha = math.min(alpha, self.alpha)
  love.graphics.setColor(self.r, self.g, self.b, alpha)
  love.graphics.rectangle('fill', x, y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

function PrototypeSprite:release()
end

return PrototypeSprite
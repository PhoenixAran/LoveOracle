local Class = require 'lib.class'

--- basic sprite
---@class Sprite
---@field subtexture Subtexture
---@field offsetX number
---@field offsetY number
---@field w number
---@field h number
---@field originX number
---@field originY number
---@field alpha number?
local Sprite = Class {
  init = function(self, subtexture, offsetX, offsetY, originX, originY, alpha)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end
    self.subtexture = subtexture
    self.offsetX = offsetX
    self.offsetY = offsetY
    local w, h = self:getDimensions()
    self.w = w
    self.h = h
    if originX == nil then
      self.originX = w / 2
    else
      self.originX = originX
    end
    if originY == nil then
      self.originY = h / 2
    else
      self.originY = originY
    end
    if alpha == nil then alpha = 1 end
    self.alpha = alpha or 1
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
  return self.w
end

function Sprite:getHeight()
  return self.h
end

function Sprite:getDimensions()
  return self.subtexture:getDimensions()
end

---gets the boundaries of this sprite
---@return number x
---@return number y
---@return number w
---@return number h
function Sprite:getBounds()
  local x, y = self:getOffset()
  local w, h = self:getDimensions()
  return x, y, w, h
end

function Sprite:getOrigin()
  return self.originX, self.originY
end

function Sprite:setOrigin(originX, originY)
  self.originX = originX
  self.originY = originY
end

function Sprite:draw(x, y, alpha, scaleX, scaleY)
  scaleX = scaleX or 1
  scaleY = scaleY or 1
  if alpha == nil then alpha = 1 end
  alpha = math.min(alpha, self.alpha)
  love.graphics.setColor(1, 1, 1, alpha)
  love.graphics.draw(self.subtexture.image, self.subtexture.quad, x + self.offsetX, y + self.offsetY, 0, scaleX, scaleY, self.originX, self.originY)
  love.graphics.setColor(1, 1, 1)
end

function Sprite:release()
  self.subtexture:release()
end

return Sprite
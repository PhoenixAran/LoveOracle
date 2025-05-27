local Class = require 'lib.class'

-- Warning: Do not put a composite sprite inside itself
-- This is a sprite composed of multiple sprites which will act
-- as one singular sprite
---@class CompositeSprite
---@field sprites Sprite[]|ColorSprite[]|PrototypeSprite[]|CompositeSprite[]
---@field boundsRect table
---@field offsetX integer
---@field offsetY integer
---@field originX number
---@field originY number
---@field alpha number?
local CompositeSprite = Class {
  init = function(self, sprites, originX, originY, offsetX, offsetY, alpha)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end

    self.sprites = sprites
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.width = 0
    self.height = 0
    self.boundsRect = { x = 0, y = 0, w = 0, h = 0 }
    self:calculateBounds()
    if originX == nil or originY == nil then
      self.originX = self.boundsRect.w / 2
      self.originY = self.boundsRect.h / 2
    else
      self.originX = originX
      self.originY = originY
    end
    if alpha == nil then
      self.alpha = 1
    else
      self.alpha = alpha
    end
  end
}

function CompositeSprite:getType()
  return 'composite_sprite'
end

function CompositeSprite:calculateBounds()
  if #self.sprites == 0 then return end
  if #self.sprites == 1 then
    self.boundsRect.x, self.boundsRect.y, self.boundsRect.w, self.boundsRect.h = self.sprites[0]:getBounds()
    return
  end
  local top = self:getTopMostBoundary()
  local bottom = self:getBottomMostBoundary()
  local left = self:getLeftMostBoundary()
  local right = self:getRightMostBoundary()
  self.boundsRect.x = self.offsetX
  self.boundsRect.y = self.offsetY
  self.boundsRect.w = right - left
  self.boundsRect.h = bottom - top
end

function CompositeSprite:getLeftMostBoundary()
  local returnVal = 10000
  for _, sprite in ipairs(self.sprites) do
    local x = sprite:getOffsetX()
    if x < returnVal then 
      returnVal = x
    end
  end
  return returnVal
end

function CompositeSprite:getRightMostBoundary()
  local returnVal = -10000
  for _, sprite in ipairs(self.sprites) do
    local x = sprite:getOffsetX() + sprite:getWidth()
    if returnVal < x then
      returnVal = x
    end
  end
  return returnVal
end

function CompositeSprite:getTopMostBoundary()
  local returnVal = 10000
  for _, sprite in ipairs(self.sprites) do
    local y = sprite:getOffsetY()
    if y < returnVal then
      returnVal = y
    end
  end
  return returnVal
end

function CompositeSprite:getBottomMostBoundary()
  local returnVal = -10000
  for _, sprite in ipairs(self.sprites) do
    local y = sprite:getOffsetY() + sprite:getHeight()
    if returnVal < y then
      returnVal = y
    end
  end
  return returnVal
end

function CompositeSprite:getOffset()
  return self.offsetX, self.offsetY
end

function CompositeSprite:getOffsetX()
  return self.offsetX
end

function CompositeSprite:getOffsetY()
  return self.offsetY
end

function CompositeSprite:getWidth()
  return self.boundsRect.w
end

function CompositeSprite:getHeight()
  return self.boundsRect.h
end

function CompositeSprite:getDimensions()
  return self.boundsRect.w, self.boundsRect.h
end

function CompositeSprite:getBounds()
  return self.boundsRect.x, self.boundsRect.y, self.boundsRect.w, self.boundsRect.h
end

function CompositeSprite:getOrigin()
  return self.originX, self.originY
end

function CompositeSprite:draw(x, y, alpha, scaleX, scaleY)
  if alpha == nil then alpha = 1 end
  alpha = math.min(alpha, self.alpha)
  for _, sprite in ipairs(self.sprites) do
    sprite:draw(x + self:getOffsetX(), y + self:getOffsetY(), alpha, scaleX, scaleY)
  end
end

function CompositeSprite:release()
  for _, sprite in ipairs(self.sprites) do
    sprite:release()
  end
end

return CompositeSprite
local Class = require 'lib.class'

local CompositeSprite = Class {
  init = function(self, sprites, offsetX, offsetY)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end

    self.sprites = sprites
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.boundsRect = { x = 0, y = 0, w = 0, h = 0 }
    self:calculateBounds()
  end
}

function CompositeSprite:getType()
  return 'compositesprite'
end

function CompositeSprite:calculateBounds()
  if #self.sprites == 0 then return end
  if #self.sprites == 1 then
    self.boundsRect.x, self.boundsRect.y, self.boundsRect.w, self.boundsRect.h = self.sprites[1]:getBounds()
    return
  end
  local top = self:getTopMostBoundary()
  local bottom = self:getBottomMostBoundary()
  local left = self:getLeftMostBoundary()
  local right = self:getRightMostBoundary()
  
  self.boundsRect.x = self.offsetX
  self.boundsRect.y = self.offsetY
  self.boundsRect.w = right - left
  self.boundsRect.y = bottom - top
end

function CompositeSprite:getLeftMostBoundary()
  local returnVal = 100000
  for _, sprite in ipairs(self.sprites) do
    local x = sprite:getOffsetX()
    if x < returnVal then 
      returnVal = x
    end
  end
  return returnVal
end

function CompositeSprite:getRightMostBoundary()
  local returnVal = -100000
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

function CompositeSprite:getBounds()
  return self.boundsRect.x, self.boundsRect.y, self.boundsRect.w, self.boundsRect.h
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

function CompositeSprite:draw(x, y, alpha)
  if alpha == nil then alpha = 1 end
  for _, sprite in ipairs(self.sprites) do
    sprite:draw(x, y, alpha)
  end
end

return CompositeSprite
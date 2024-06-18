local Class = require 'lib.class'

---@class EmptySprite
local EmptySprite = Class {
  init = function()
  end
}

function EmptySprite:getType()
  return 'empty_sprite'
end

function EmptySprite:getOffset()
  return 0, 0
end

function EmptySprite:getOffsetX()
  return 0
end

function EmptySprite:getOffsetY()
  return 0
end

function EmptySprite:getWidth()
  return 1
end

function EmptySprite:getHeight()
  return 1
end

function EmptySprite:getDimensions()
  return 1, 1
end

function EmptySprite:getBounds()
  return 0, 0, 1, 1
end

function EmptySprite:getOrigin()
  return 0.5, 0.5
end

-- its an empty sprite, so dont do anything
function EmptySprite:draw(x, y, alpha)
end

function EmptySprite:release()
end

return EmptySprite
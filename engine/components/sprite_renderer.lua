local Class = require 'lib.class'
local Component = require 'engine.entities.component'

local SpriteRenderer = Class { __includes = Component,
  init = function(self, sprite, offsetX, offsetY, enabled, visible)
    Component.init(self, enabled, visible)
  
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end
    
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.sprite = sprite
    self.alpha = 0
    self:setSprite(self.sprite)
  end
}

function SpriteRenderer:setSprite(sprite)
  self.sprite = sprite
end

function SpriteRenderer:getType()
  return 'spriterenderer'
end

function SpriteRenderer:getOffsetX()
  return self.offsetX
end

function SpriteRenderer:getOffsetY()
  return self.offsetY
end

function SpriteRenderer:getOffset()
  return self.offsetX, self.offsetY
end

function SpriteRenderer:setOffset(x, y)
  self.offsetX = x
  self.offsetY = y
end

function SpriteRenderer:getBounds()
  local ex, ey = self.entity:getPosition()
  local x,y,w,h = self.sprite:getBounds()
  local ox, oy = self.sprite:getOrigin()
  local z = self.entity:getZPosition()
  x = x + ex + self.offsetX - ox
  y = y + ey + self.offsetY - oy - y
  return x, y, w, h
end

function SpriteRenderer:draw()
  local x, y = self.entity:getPosition()
  local z = self.entity:getZPosition()
  x = x + self.offsetX
  y = y + self.offsetY
  self.sprite:draw(x, y - z)
end

function SpriteRenderer:debugDraw()
  local x, y, w, h = self:getBounds()
  love.graphics.setColor(0, 1, 0)
  love.graphics.rectangle('line', x, y, w, h)
  love.graphics.setColor(1, 1, 1)
end

return SpriteRenderer
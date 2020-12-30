local Class = require 'lib.class'
local Component = require 'engine.entities.component'

local SpriteRenderer = Class { __includes = Component,
  init = function(self, entity, sprite, offsetX, offsetY, followZ, enabled, visible)
    Component.init(self, entity, enabled, visible)
  
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end
    if followZ == nil then followZ = true end
    
    self.offsetX = offsetX
    self.offsetY = offsetY
    self.sprite = sprite
    self.followZ = followZ
    self.alpha = 1
    self.color = { }
    self:setSprite(self.sprite)
    
  end
}

function SpriteRenderer:getType()
  return 'sprite_renderer'
end

function SpriteRenderer:setSprite(sprite)
  self.sprite = sprite
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
  if self.sprite == nil then
    return 0, 0, 0, 0
  end
  local ex, ey = self.entity:getPosition()
  local x,y,w,h = self.sprite:getBounds()
  local ox, oy = self.sprite:getOrigin()
  local z = self.entity:getZPosition()
  x = x + ex + self.offsetX - ox
  y = y + ey + self.offsetY - oy
  if self.followZ then
    y = y - z
  end
  return x, y, w, h
end

function SpriteRenderer:draw()
  if self.sprite == nil then
    return
  end
  local x, y = self.entity:getPosition()
  local z = self.entity:getZPosition()
  x = x + self.offsetX
  y = y + self.offsetY
  if self.followZ then
    self.sprite:draw(x, y - z, self.alpha)
  else
    self.sprite:draw(x, y, self.alpha)
  end
end

function SpriteRenderer:debugDraw()
  if self.sprite == nil then
    return
  end
  local x, y, w, h = self:getBounds()
  love.graphics.setColor(0, 1, 0)
  love.graphics.rectangle('line', x, y, w, h)
  love.graphics.setColor(1, 1, 1)
end

return SpriteRenderer
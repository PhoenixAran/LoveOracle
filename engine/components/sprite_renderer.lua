local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local PaletteBank = require 'engine.utils.palette_bank'

local SpriteRenderer = Class { __includes = Component,
  init = function(self, entity, args)
    Component.init(self, entity, args)

    if args.offsetX == nil then args.offsetX = 0 end
    if args.offsetY == nil then args.offsetY = 0 end
    if args.alpha == nil then args.alpha = 1 end
    if args.followZ == nil then args.followZ = true end

    self.palette = args.palette
    self.offsetX = args.offsetX
    self.offsetY = args.offsetY
    self.sprite = args.sprite
    self.followZ = args.followZ
    self.alpha = args.alpha
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

function SpriteRenderer:setAlpha(value)
  self.alpha = value
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

function SpriteRenderer:getPalette()
  return self.palette
end

function SpriteRenderer:setPalette(palette)
  self.palette = palette
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
    y = y - z
  end
  if self.palette == nil then
    self.sprite:draw(x, y, self.alpha)
  else
    love.graphics.setShader(self.palette:getShader())
    self.sprite:draw(x, y, self.alpha)
    love.graphics.setShader()
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
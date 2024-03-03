local Class = require 'lib.class'
local AssetManager = require 'engine.asset_manager'
local PaletteBank = require 'engine.banks.palette_bank'

-- Acts as a sprite.
-- Will override the current palette shader.
-- Useful if sprite doesnt match your current color palette
-- defined in your SpriteRenderer or current Tile Set Theme

---@class ColorSprite
---@field sprite Sprite
---@field palette Palette
---@field offsetX number
---@field offsetY number
local ColorSprite = Class {
  init = function(self, sprite, palette, offsetX, offsetY)
    if offsetX == nil then offsetX = 0 end
    if offsetY == nil then offsetY = 0 end
    
    if type(sprite) == 'string' then
      sprite = AssetManager.getSprite(sprite)
    end
    if type(palette) == 'string' then
      palette = PaletteBank.getPalette(palette)
    end
    self.sprite = sprite
    self.palette = palette
    self.offsetX = offsetX
    self.offsetY = offsetY
  end
}

function ColorSprite:getType()
  return 'color_sprite'
end

function ColorSprite:getOffset()
  local sx, sy = self.sprite:getOffset()
  return self.offsetX + sx, self.offsetY + sy
end

function ColorSprite:getOffsetX()
  return self.offsetX + self.sprite:getOffsetX()
end

function ColorSprite:getOffsetY()
  return self.offsetY + self.sprite:getOffsetY()
end

function ColorSprite:getWidth()
  return self.sprite:getWidth()
end

function ColorSprite:getHeight()
  return self.sprite:getHeight()
end

function ColorSprite:getDimensions()
  return self.sprite:getDimensions()
end

function ColorSprite:getBounds()
  local sx, sy = self.sprite:getBounds()
  local x = self.offsetX + sx
  local y = self.offsetY + sy
  local w, h = self:getDimensions()
  return x, y, w, h
end

function ColorSprite:getOrigin()
  return self.sprite:getOrigin()
end

function ColorSprite:draw(x, y, alpha)
  x = x + self:getOffsetX()
  y = y + self:getOffsetY()
  local currentShader = love.graphics.getShader()
  local shouldSwapBack = currentShader ~= self.palette:getShader()
  if shouldSwapBack then
    love.graphics.setShader(self.palette:getShader())
  end
  self.sprite:draw(x, y, alpha)
  if shouldSwapBack then
    love.graphics.setShader(currentShader)
  end
end

function ColorSprite:release()
  self.sprite:release()
end

return ColorSprite
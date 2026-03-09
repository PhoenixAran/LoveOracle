local Class = require 'lib.class'
local lume = require 'lib.lume'

--- A 9-patch sprite that scales for UI elements
--- The image is divided into 9 regions: 4 corners, 4 edges, and 1 center
--- Corners don't scale, edges scale in one direction, center scales both ways
---@class NinePatchSprite
---@field ninePatchTexture NinePatchTexture nine patch texture
---@field width number the total width of the 9-patch
---@field height number the total height of the 9-patch
---@field originX number the x-coordinate of the origin point for drawing
---@field originY number the y-coordinate of the origin point for drawing
---@field alpha number
local NinePatchSprite = Class {
  init = function(self, ninePatchTexture, width, height, alpha)
    self.ninePatchTexture = ninePatchTexture
    self.width = width
    self.height = height
    self.originX = width / 2
    self.originY = height / 2
    self.height = height / 2
    self.alpha = alpha or 1
  end
}

function NinePatchSprite:getType()
  return 'nine_patch_sprite'
end

function NinePatchSprite:getWidth()
  return self.width
end

function NinePatchSprite:setWidth(width)
  self.width = width
  self.originX = width / 2
end

function NinePatchSprite:setHeight(height)
  self.height = height
  self.originY = height / 2
end

function NinePatchSprite:getHeight()
  return self.height
end

function NinePatchSprite:getDimensions()
  return self.width, self.height
end

function NinePatchSprite:getOrigin()
  return self.originX, self.originY
end

---gets the boundaries of this sprite
---@return number x
---@return number y
---@return number w
---@return number h
function NinePatchSprite:getBounds()
  local w, h = self:getDimensions()
  return 0, 0, w, h
end

---@param x number
---@param y number
---@param alpha number?   -- 0..1
function NinePatchSprite:draw(x, y, alpha)
  alpha = alpha or 1

  -- position is for the *top-left* of the final rect, respecting origin
  x = x - self.originX
  y = y - self.originY

  local s = self.ninePatchTexture:getSubtextures()

  -- Dimensions per patch (pixels in the source texture)
  local w1,h1 = s[1]:getDimensions()
  local w2,h2 = s[2]:getDimensions()
  local w3,h3 = s[3]:getDimensions()

  local w4,h4 = s[4]:getDimensions()
  local w5,h5 = s[5]:getDimensions()
  local w6,h6 = s[6]:getDimensions()

  local w7,h7 = s[7]:getDimensions()
  local w8,h8 = s[8]:getDimensions()
  local w9,h9 = s[9]:getDimensions()

  -- Corner sizes in the final rect (keep corners unscaled by default)
  local leftW   = w1
  local rightW  = w3
  local topH    = h1
  local bottomH = h7

  -- Center area size (clamp so it never goes negative)
  local centerW = math.max(0, self.width - leftW - rightW)
  local centerH = math.max(0, self.height - topH - bottomH)

  love.graphics.setColor(1, 1, 1, alpha)

  -- Row 1
  self:drawPatch(x,                 y,                  s[1], 1, 1)
  self:drawPatch(x + leftW,         y,                  s[2], centerW / w2, 1)
  self:drawPatch(x + leftW+centerW, y,                  s[3], 1, 1)

  -- Row 2
  self:drawPatch(x,                 y + topH,           s[4], 1, centerH / h4)
  self:drawPatch(x + leftW,         y + topH,           s[5], centerW / w5, centerH / h5)
  self:drawPatch(x + leftW+centerW, y + topH,           s[6], 1, centerH / h6)

  -- Row 3
  self:drawPatch(x,                 y + topH+centerH,   s[7], 1, 1)
  self:drawPatch(x + leftW,         y + topH+centerH,   s[8], centerW / w8, 1)
  self:drawPatch(x + leftW+centerW, y + topH+centerH,   s[9], 1, 1)

  love.graphics.setColor(1, 1, 1, 1)
end

---@param drawX number
---@param drawY number
---@param subtexture table
---@param scaleX number
---@param scaleY number
function NinePatchSprite:drawPatch(drawX, drawY, subtexture, scaleX, scaleY)
  love.graphics.draw(subtexture.image, subtexture.quad, drawX, drawY, 0, scaleX, scaleY)
end
function NinePatchSprite:release()
end

return NinePatchSprite
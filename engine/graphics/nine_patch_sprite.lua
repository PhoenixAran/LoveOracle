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

---Helper function to draw a single patch region
---@param x number screen x position
---@param y number screen y position
---@param scaleX number x scale factor
---@param scaleY number y scale factor
function NinePatchSprite:draw(x, y, alpha, scaleX, scaleY)
-- Adjust x and y to scale around the center
  local w, h = self.width * scaleX, self.height * scaleY
  x = x - self.originX * scaleX
  y = y - self.originY * scaleY
  
  local subtextures = self.ninePatchTexture:getSubtextures()

  -- Get corner/edge dimensions
  local cornerW1, cornerH1 = subtextures[1]:getDimensions()
  local edgeW2, edgeH2 = subtextures[2]:getDimensions()
  local cornerW3, cornerH3 = subtextures[3]:getDimensions()
  local edgeW4, edgeH4 = subtextures[4]:getDimensions()
  local centerW5, centerH5 = subtextures[5]:getDimensions()

  -- Calculate scaled dimensions
  local scaledCornerW = cornerW1 * scaleX
  local scaledCornerH = cornerH1 * scaleY
  local scaledEdgeW = edgeW4 * scaleX
  local scaledCenterW = self.width * scaleX - (scaledCornerW * 2)
  local scaledCenterH = self.height * scaleY - (scaledCornerH * 2)

  love.graphics.setColor(1, 1, 1, alpha)

  -- Draw the 9 patches
  -- Top-left (1)
  self:drawPatch(x, y, subtextures[1], 1, 1)

  -- Top (2)
  self:drawPatch(x + scaledCornerW, y, subtextures[2], scaledCenterW / edgeW2, 1)

  -- Top-right (3)
  self:drawPatch(x + scaledCornerW + scaledCenterW, y, subtextures[3], 1, 1)

  -- Left (4)
  self:drawPatch(x, y + scaledCornerH, subtextures[4], 1, scaledCenterH / edgeH4)

  -- Center (5)
  self:drawPatch(x + scaledCornerW, y + scaledCornerH, subtextures[5], scaledCenterW / centerW5, scaledCenterH / centerH5)

  -- Right (6)
  self:drawPatch(x + scaledCornerW + scaledCenterW, y + scaledCornerH, subtextures[6], 1, scaledCenterH / edgeH4)

  -- Bottom-left (7)
  self:drawPatch(x, y + scaledCornerH + scaledCenterH, subtextures[7], 1, 1)

  -- Bottom (8)
  self:drawPatch(x + scaledCornerW, y + scaledCornerH + scaledCenterH, subtextures[8], scaledCenterW / edgeW2, 1)

  -- Bottom-right (9)
  self:drawPatch(x + scaledCornerW + scaledCenterW, y + scaledCornerH + scaledCenterH, subtextures[9], 1, 1)

  love.graphics.setColor(1, 1, 1)
end

---Helper function to draw a single patch region
---@param drawX number screen x position
---@param drawY number screen y position
---@param scaleX number x scale factor
---@param scaleY number y scale factor
function NinePatchSprite:drawPatch(drawX, drawY, subtexture, scaleX, scaleY)
  love.graphics.draw(subtexture.image, subtexture.quad, drawX, drawY, 0, scaleX, scaleY)
end

function NinePatchSprite:release()
end

return NinePatchSprite
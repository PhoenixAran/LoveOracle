local Class = require 'lib.class'
local lume = require 'lib.lume'

local Sprite = require 'engine.graphics.sprite'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local CompositeSprite = require 'engine.graphics.composite_sprite'
local ColorSprite = require 'engine.graphics.color_sprite'

local AssetManager = require 'engine.utils.asset_manager'

---Builds singular sprite instances
---This is just convenient access to all the different Sprite type constructors
---to be used for data scripting
---@class SpriteBuilder
---@field spriteSheet SpriteSheet
---@field sprites Sprite[]
local SpriteBuilder = Class {
  init = function(self)
    self.spriteSheet = nil
    -- used for building composite sprites
    self.sprites = { }
  end
}

---@return string
function SpriteBuilder:getType()
  return 'sprite_builder'
end

---sets current SpriteSheet context
---@param spriteSheet string|SpriteSheet
function SpriteBuilder:setSpriteSheet(spriteSheet)
  if type(spriteSheet) == 'string' then
    self.spriteSheet = AssetManager.getSpriteSheet(spriteSheet)
  else
    self.spriteSheet = spriteSheet
  end
end

---builds a basic sprite
---@param x integer
---@param y integer
---@param offsetX number?
---@param offsetY number?
---@return unknown
function SpriteBuilder:buildSprite(x, y, offsetX, offsetY)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, offsetX, offsetY)
  return sprite
end

---adds a sprite to be used for a CompositeSprite
---@param sprite Sprite
function SpriteBuilder:addCompositeSprite(sprite)
  lume.push(self.sprites, sprite)
end

---builds composite sprite. CompositeSprite array will then be cleared
---@param sprite Sprite
---@param originX number?
---@param originY number?
---@param offsetX number?
---@param offsetY number?
---@return CompositeSprite
function SpriteBuilder:buildCompositeSprite(sprite, originX, originY, offsetX, offsetY)
  self.sprites = { }
  return CompositeSprite(self.sprites, originX, originY, offsetX, offsetY)
end

---builds prototype sprite
---@param r number
---@param g number
---@param b number
---@param width integer
---@param height integer
---@param offsetX number
---@param offsetY number
---@param delay integer
---@return PrototypeSprite
function SpriteBuilder:buildPrototypeSprite(r, g, b, width, height, offsetX, offsetY, delay)
  return PrototypeSprite(r, g, b, width, height, offsetX, offsetY)
end

---builds Color Sprite
---@param sprite Sprite
---@param paletteKey string
---@param offsetX number
---@param offsetY number
---@return ColorSprite
function SpriteBuilder:buildColorSprite(sprite, paletteKey, offsetX, offsetY)
  return ColorSprite(sprite, paletteKey, offsetX, offsetY)
end

return SpriteBuilder
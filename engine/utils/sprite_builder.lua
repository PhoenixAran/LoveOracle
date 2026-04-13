local Class = require 'lib.class'
local lume = require 'lib.lume'

local Sprite = require 'engine.graphics.sprite'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local CompositeSprite = require 'engine.graphics.composite_sprite'
local ColorSprite = require 'engine.graphics.color_sprite'
local NinePatchSprite = require 'engine.graphics.nine_patch_sprite'

local AssetManager = require 'engine.asset_manager'
local Subtexture = require 'engine.graphics.subtexture'

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

--- get the current underlying spritesheet
---@return SpriteSheet?
function SpriteBuilder:getSpriteSheet()
  return self.spriteSheet
end

---builds a basic sprite
---@param x integer
---@param y integer
---@param offsetX number?
---@param offsetY number?
---@return Sprite
function SpriteBuilder:buildSprite(x, y, offsetX, offsetY)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, offsetX, offsetY)
  return sprite
end

---builds a basic sprite from a given image
---@param imageKey string
---@param offsetX number?
---@param offsetY number?
function SpriteBuilder:buildSpriteFromImage(imageKey, offsetX, offsetY)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  local image = AssetManager.getImage(imageKey)
  local subtexture = Subtexture(image, love.graphics.newQuad(0, 0, image:getWidth(), image:getHeight(), image:getWidth(), image:getHeight()))
  local sprite = Sprite(subtexture, offsetX, offsetY)
  return sprite
end

---adds a sprite to be used for a CompositeSprite
---@param sprite Sprite
function SpriteBuilder:addCompositeSprite(sprite)
  lume.push(self.sprites, sprite)
end

---builds composite sprite. CompositeSprite array will then be cleared
---@param offsetX number?
---@param offsetY number?
---@param originX number?
---@param originY number?
---@return CompositeSprite
function SpriteBuilder:buildCompositeSprite(offsetX, offsetY, originX, originY)
  local compositeSprite = CompositeSprite(self.sprites, offsetX, offsetY, originX, originY)
  self.sprites = { }  
  return compositeSprite
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


--- builds nine patch sprite
--- Note that this takes NinePatchTextures, so it is independent from the spritesheet
---@param ninePatchTexture NinePatchTexture
---@param width integer?
---@param height integer?
---@param alpha number?
function SpriteBuilder:buildNinePatchSprite(ninePatchTexture, width, height, alpha)
  return NinePatchSprite(ninePatchTexture, width, height, alpha)
end

return SpriteBuilder
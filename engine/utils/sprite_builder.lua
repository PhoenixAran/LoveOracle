local Class = require 'lib.class'
local lume = require 'lib.lume'

local Sprite = require 'engine.graphics.sprite'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local CompositeSprite = require 'engine.graphics.composite_sprite'
local ColorSprite = require 'engine.graphics.color_sprite'

local AssetManager = require 'engine.utils.asset_manager'

-- builds singular sprite instances
-- This is just convenient access to all the different Sprite type constructors
-- to be used for data scripting
local SpriteBuilder = Class {
  init = function(self)
    self.spriteSheet = nil
    -- used for building composite sprites
    self.sprites = { }
  end
}

function SpriteBuilder:getType()
  return 'sprite_builder'
end

function SpriteBuilder:setSpriteSheet(spriteSheet)
  if type(spriteSheet) == 'string' then
    self.spriteSheet = AssetManager.getSpriteSheet(spriteSheet)
  else
    self.spriteSheet = spriteSheet
  end
end

function SpriteBuilder:buildSprite(x, y, offsetX, offsetY)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, offsetX, offsetY)
end

function SpriteBuilder:addCompositeSprite(sprite)
  lume.push(self.sprites, sprite)
end

function SpriteBuilder:buildCompositeSprite(sprite, originX, originY, offsetX, offsetY)
  self.sprites = { }
  return CompositeSprite(self.sprites, originX, originY, offsetX, offsetY)
end

function SpriteBuilder:buildPrototypeSprite(r, g, b, width, height, offsetX, offsetY, delay)
  return PrototypeSprite(r, g, b, width, height, offsetX, offsetY)
end

function SpriteBuilder:buildColorSprite(sprite, paletteKey, offsetX, offsetY)
  return ColorSprite(sprite, paletteKey, offsetX, offsetY)
end

return SpriteBuilder


local Class = require 'lib.class'
local lume = require 'lib.lume'

local Sprite = require 'engine.graphics.sprite'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local CompositeSprite = require 'engine.graphics.composite_sprite'

local AssetManager = require 'engine.utils.asset_manager'

-- builds singular sprite instances
local SpriteBuilder = Class {
  init = function(self)
    self.spriteSheet = nil
    self.compositeFrames = { }
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



return SpriteBuilder


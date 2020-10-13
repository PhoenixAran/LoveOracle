local Class = require 'lib.class'
local Sprite = require 'engine.graphics.sprite'
local CompositeSprite = require 'engine.graphics.composite_sprite'
local SpriteFrame = require 'engine.graphics.sprite_frame'
local SpriteAnimation = require 'engine.graphics.sprite_animation'
local lume = require 'lib.lume'

local SpriteAnimationBuilder = Class {
  init = function(self)
    self.spriteSheet = nil
    self.frames = { }
    self.compositeSprites = { }
    self.timedActions = { }
    self.loopType = 'once'
    self.defaultLoopType = 'once'
  end
}

function SpriteAnimationBuilder:setLoopType(loopType)
  self.loopType = loopType
end

function SpriteAnimationBuilder:setDefaultLoopType(loopType, overrideCurrentLoopType)
  self.defaultLoopType = loopType
  if overrideCurrentLoopType then
    self.loopType = loopType
  end
end

function SpriteAnimationBuilder:setSpriteSheet(spriteSheet)
  assert(assetManager, 'Global variable "assetManager" instance does not exist')
  if type(spriteSheet) == 'string' then
    assetManager.getSpriteSheet(spriteSheet)
  else
    self.spriteSheet = spriteSheet
  end
end

-- adds a regular sprite frame using the curren tinternal spritesheet
function SpriteAnimationBuilder:addSpriteFrame(x, y, offsetX, offsetY, delay)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  
  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, x, y, offsetX, offsetY)
  local spriteFrame = SpriteFrame(sprite, delay)
  lume.push(self.frames, spriteFrame)
end

-- add a sprite to the composite sprite table using the current internal spritesheet
function SpriteAnimationBuilder:addCompositeSprite(x, y, offsetX, offsetY)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  
  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, x, y, offsetX, offsetY)
  lume.push(self.compositeSprites, sprite)
end

-- use the current stored sprite frames to make composite sprite frames
function SpriteAnimationBuilder:addCompositeSpriteFrame(originX, originY, offsetX, offsetY, delay)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  
  local compositeSprite = CompositeSprite(self.compositeSprites, originX, originY, offsetX, offsetY)
  local spriteFrame = SpriteFrame(compositeSprite, delay)
  lume.push(self.frames, spriteFrame)
  self.compositeSprites = { }
end

function SpriteAnimationBuilder:addTimedAction(tick, func)
  self.timedActions[tick] = func
end

function SpriteAnimationBuilder:buildAnimation()
  local animation = SpriteAnimation(self.frames, self.timedActions, self.loopType)
  self.frames = { }
  self.timedActions = { }
  self.compositeSprites = { }
  self.loopType = self.defaultLoopType
  return animation
end
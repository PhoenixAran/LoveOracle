local Class = require 'lib.class'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
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
    
    self.hasSubstrips = false
    self.subFrames = { }
    self.subTimedActions = { }
  end
}

function SpriteAnimationBuilder:setSubstrips(bool)
  self.hasSubstrips = bool
end

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
    self.spriteSheet = assetManager.getSpriteSheet(spriteSheet)
  else
    self.spriteSheet = spriteSheet
  end
end

-- adds a regular sprite frame using the curren tinternal spritesheet
function SpriteAnimationBuilder:addSpriteFrame(x, y, offsetX, offsetY, delay)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  
  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, offsetX, offsetY)
  local spriteFrame = SpriteFrame(sprite, delay)
  lume.push(self.frames, spriteFrame)
end

-- add a sprite to the composite sprite table using the current internal spritesheet
function SpriteAnimationBuilder:addCompositeSprite(x, y, offsetX, offsetY)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  
  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, offsetX, offsetY)
  lume.push(self.compositeSprites, sprite)
end

-- use the current stored sprite frames to make composite sprite frames
function SpriteAnimationBuilder:addCompositeFrame(originX, originY, offsetX, offsetY, delay)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end
  
  local compositeSprite = CompositeSprite(self.compositeSprites, originX, originY, offsetX, offsetY)
  local spriteFrame = SpriteFrame(compositeSprite, delay)
  lume.push(self.frames, spriteFrame)
  self.compositeSprites = { }
end

function SpriteAnimationBuilder:addPrototypeFrame(r, g, b, width, height, offsetX, offsetY, delay) 
  local sprite = PrototypeSprite(r, g, b, width, height, offsetX, offsetY)
  local spriteFrame = SpriteFrame(sprite, delay)
  lume.push(self.frames, spriteFrame)
end

function SpriteAnimationBuilder:addTimedAction(tick, func)
  self.timedActions[tick] = func
end

function SpriteAnimationBuilder:buildSubstrip(substripKey, makeDefault)
  if makeDefault == nil then
    makeDefault = false
  end
  
  self.subFrames[substripKey] = self.frames
  self.subTimedActions[substripKey] = self.timedActions
  
  if makeDefault then
    self.subFrames[1] = self.frames
    self.subTimedActions[1] = self.timedActions
  end
  
  self.frames = { }
  self.timedActions = { }
  self.compositeSprites = { }
end

function SpriteAnimationBuilder:build()
  local animation = nil
  if self.hasSubstrips then
    animation = SpriteAnimation(self.subFrames, self.subTimedActions, self.loopType, true)
    self.subFrames = { }
    self.subTimedActions = { }
  else
    animation = SpriteAnimation(self.frames, self.timedActions, self.loopType, false)
  end
  self.frames = { }
  self.timedActions = { }
  self.compositeSprites = { }
  self.loopType = self.defaultLoopType
  self.hasSubstrips = false
  return animation
end

return SpriteAnimationBuilder
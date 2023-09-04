local Class = require 'lib.class'
local lume = require 'lib.lume'

local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local Sprite = require 'engine.graphics.sprite'
local CompositeSprite = require 'engine.graphics.composite_sprite'
local SpriteFrame = require 'engine.graphics.sprite_frame'
local SpriteAnimation = require 'engine.graphics.sprite_animation'
local Direction4 = require 'engine.enums.direction4'

local assetManager = require 'engine.utils.asset_manager'

local DEFAULT_KEY = 'default'

---@class SpriteAnimationBuilder
---@field spriteSheet SpriteSheet
---@field frames SpriteFrame[]
---@field compositeSprites Sprite[]
---@field timedActions table<integer, function>
---@field loopType string
---@field defaultLoopType string
---@field hasSubstrips boolean
---@field subFrames table<string, SpriteFrame[]>
---@field subTimedActions table<integer, function[]>
---@field Direction4 table<string, integer>
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
    -- easy access to Direction4 enums for data scripting
    self.Direction4 = Direction4
  end
}

---@return string
function SpriteAnimationBuilder:getType()
  return 'sprite_animation_builder'
end

---toggles substrip animation building
---@param bool boolean
function SpriteAnimationBuilder:setSubstrips(bool)
  self.hasSubstrips = bool
end

---sets looptype when animation is built
---@param loopType string
function SpriteAnimationBuilder:setLoopType(loopType)
  self.loopType = loopType
end

---sets the default looptype
---@param loopType string
---@param overrideCurrentLoopType boolean?
function SpriteAnimationBuilder:setDefaultLoopType(loopType, overrideCurrentLoopType)
  self.defaultLoopType = loopType
  if overrideCurrentLoopType then
    self.loopType = loopType
  end
end

---sets the current spritesheet
---@param spriteSheet string|SpriteSheet
function SpriteAnimationBuilder:setSpriteSheet(spriteSheet)
  if type(spriteSheet) == 'string' then
    self.spriteSheet = assetManager.getSpriteSheet(spriteSheet)
  else
    self.spriteSheet = spriteSheet
  end
end

---adds a regular sprite frame using the current internal spritesheet
---@param x integer | Sprite
---@param y integer?
---@param offsetX number?
---@param offsetY number?
---@param delay integer?
function SpriteAnimationBuilder:addSpriteFrame(x, y, offsetX, offsetY, delay)
  -- user is adding an explicit Sprite object
  if type(x) == 'table' then
    -- x becomes a Sprite instance
    -- y becomes the delay
    delay = y
    lume.push(self.frames, SpriteFrame(x, y))
    return
  end
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end

  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, offsetX, offsetY)
  local spriteFrame = SpriteFrame(sprite, delay)
  lume.push(self.frames, spriteFrame)
end

---add a sprite to the composite sprite table using the current internal spritesheet
---@param x integer
---@param y integer
---@param offsetX number
---@param offsetY number
function SpriteAnimationBuilder:addCompositeSprite(x, y, offsetX, offsetY)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end

  local subtexture = self.spriteSheet:getTexture(x, y)
  local sprite = Sprite(subtexture, offsetX, offsetY)
  lume.push(self.compositeSprites, sprite)
end

---use the current stored sprite frames to make composite sprite frames
---@param originX number
---@param originY number
---@param offsetX number
---@param offsetY number
---@param delay integer
function SpriteAnimationBuilder:addCompositeFrame(originX, originY, offsetX, offsetY, delay)
  if offsetX == nil then offsetX = 0 end
  if offsetY == nil then offsetY = 0 end

  local compositeSprite = CompositeSprite(self.compositeSprites, originX, originY, offsetX, offsetY)
  local spriteFrame = SpriteFrame(compositeSprite, delay)
  lume.push(self.frames, spriteFrame)
  self.compositeSprites = { }
end

---create a SpriteFrame with a PrototypeSprite type
---@param r number
---@param g number
---@param b number
---@param width integer
---@param height integer
---@param offsetX number
---@param offsetY number
---@param delay integer
function SpriteAnimationBuilder:addPrototypeFrame(r, g, b, width, height, offsetX, offsetY, delay)
  local sprite = PrototypeSprite(r, g, b, width, height, offsetX, offsetY)
  local spriteFrame = SpriteFrame(sprite, delay)
  lume.push(self.frames, spriteFrame)
end

---add a timed action to the animation
---@param tick integer
---@param func function
function SpriteAnimationBuilder:addTimedAction(tick, func)
  self.timedActions[tick] = func
end

---build substrip with current content
---@param substripKey string|integer
---@param makeDefault boolean?
function SpriteAnimationBuilder:buildSubstrip(substripKey, makeDefault)
  if makeDefault == nil then
    makeDefault = false
  end
  if type(substripKey) == 'string' then
    substripKey = Direction4[substripKey]
  end
  assert(substripKey ~= nil, 'Substrip key out of range')
  self.subFrames[substripKey] = self.frames
  self.subTimedActions[substripKey] = self.timedActions

  if makeDefault then
    self.subFrames[DEFAULT_KEY] = self.frames
    self.subTimedActions[DEFAULT_KEY] = self.timedActions
  end

  self.frames = { }
  self.timedActions = { }
  self.compositeSprites = { }
end

---build sprite animation
---internal content will be cleared after it is built
---@return SpriteAnimation
function SpriteAnimationBuilder:build()
  local animation = nil
  if self.hasSubstrips then
    animation = SpriteAnimation(self.subFrames, self.subTimedActions, self.loopType, true)
  else
    animation = SpriteAnimation(self.frames, self.timedActions, self.loopType, false)
  end
  self.subFrames = { }
  self.subTimedActions = { }
  self.frames = { }
  self.timedActions = { }
  self.compositeSprites = { }
  self.loopType = self.defaultLoopType
  self.hasSubstrips = false
  return animation
end


return SpriteAnimationBuilder
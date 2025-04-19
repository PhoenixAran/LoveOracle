local Class = require 'lib.class'
local lume = require 'lib.lume'

local States = {
  None = 0,
  Running = 1,
  Paused = 2,
  Completed = 3
}

---helper class that keeps track of sprite animation indices for you
---This is used in many instances throughout the engine (AnimatedSpriteRenderer, Tiles with animations, Effect entities)
---@class SpriteAnimationUpdater
---@field state integer
---@field substripKey integer
---@field currentAnimationKey string
---@field currentAnimation SpriteAnimation
---@field currentFrameIndex integer
---@field currentTick integer
---@field loopType string
---@field speed number number between 0 and 1 that determines the speed animations play at
local SpriteAnimationUpdater = Class {
  init = function(self)
    self.state = States.None
    self.substripKey = nil
    self.currentAnimation = nil
    self.currentFrameIndex = 1
    self.currentTick = 1
    self.loopType = 'once'
    self.speed = 1
  end
}

function SpriteAnimationUpdater:getType()
  return 'sprite_animation_updater'
end

function SpriteAnimationUpdater:isPlaying()
  return self.state == States.Running
end

function SpriteAnimationUpdater:isCompleted()
  return self.state == States.Completed
end

function SpriteAnimationUpdater:getCurrentAnimationKey()
  return self.currentAnimationKey
end

function SpriteAnimationUpdater:getCurrentFrameIndex()
  return self.currentFrameIndex
end

function SpriteAnimationUpdater:getCurrentAnimation()
  return self.currentAnimation
end

function SpriteAnimationUpdater:setCurrentAnimation(animation)
  self.currentAnimation = animation
end

function SpriteAnimationUpdater:getCurrentTick()
  return self.currentTick
end

function SpriteAnimationUpdater:getAnimationState()
  return self.state
end

function SpriteAnimationUpdater:getLoopType()
  return self.loopType
end

function SpriteAnimationUpdater:setSpeed(speed)
  self.speed = speed
end

function SpriteAnimationUpdater:getSpeed()
  return self.speed
end

function SpriteAnimationUpdater:setSubstripKey(substripKey)
  self.substripKey = substripKey
end

function SpriteAnimationUpdater:getSubstripKey()
  return self.substripKey
end

---set animation the updater will use
---@param animation SpriteAnimation?
---@param substripKey Direction4?
---@param forcePlayFromStart boolean? if true, the animation will be played from the start even if it was already playing
function SpriteAnimationUpdater:play(animation, substripKey, forcePlayFromStart)
  if forcePlayFromStart == nil then forcePlayFromStart = false end
  local playFromStart = forcePlayFromStart
  if animation ~= nil then
    playFromStart = playFromStart or self.currentAnimation ~= animation
    self.currentAnimation = animation
  end
  if substripKey ~= nil then
    playFromStart = playFromStart or self.substripKey ~= substripKey
    self.substripKey = substripKey
  end
  playFromStart = playFromStart or self.state == States.Completed
  if playFromStart then
    self.currentFrameIndex = 1
    self.currentTick = 1
  end
  self.loopType = self.currentAnimation.loopType
  self.state = States.Running
end

function SpriteAnimationUpdater:pause()
  self.state = States.Paused
end


function SpriteAnimationUpdater:stop()
  self.currentFrameIndex = 1
  self.currentTick = 1
  self.state = States.None

  if self.currentAnimation then
    self.loopType = self.currentAnimation.loopType
  end
end

---This function does not stop the animation, but resets the current frame index and tick count.
---It will then play it if it was playing before.
function SpriteAnimationUpdater:reset()
  self:stop()
  self.state = States.Running
end

---Updates the animation state and returns the current sprite frame and its associated action, if any.
---
---If the animation is not playing, the function returns nothing.
---If the animation has no sprite frames, returns `nil, nil`.
---Otherwise, returns the current `SpriteFrame` and an optional `TimedAction` function.
---
---@return SpriteFrame? currentFrame The current sprite frame, or nil if there are none.
---@return function? timedAction A timed action associated with the current frame, or nil. Function takes entity as argument
function SpriteAnimationUpdater:update()
  if not self:isPlaying() then
    return nil, nil
  end
  if self.currentAnimation == nil then
    return nil, nil
  end
  local timedActions = self.currentAnimation:getTimedActions(self.substripKey)
  local spriteFrames = self.currentAnimation:getSpriteFrames(self.substripKey)
  local timedAction = timedActions[self.currentFrameIndex]

  -- some animation can have no spriteframes and just action frames
  if #spriteFrames == 0 then
    return nil, nil
  end

  local currentFrame = spriteFrames[self.currentFrameIndex]
  self.currentTick = self.currentTick + 1
  if currentFrame:getDelay() < self.currentTick * self.speed then
    self.currentTick = 1
    self.currentFrameIndex = self.currentFrameIndex + 1
    if #spriteFrames < self.currentFrameIndex then
      if self.loopType == 'once' then
        self.state = States.Completed
        self.currentFrameIndex = self.currentFrameIndex - 1
      elseif self.loopType == 'cycle' then
        self.currentFrameIndex = 1
      end
    end
    currentFrame = spriteFrames[self.currentFrameIndex]
  end

  return currentFrame, timedAction
end

--- depends on indices updated in SpriteAnimationUpdater:update()
---@return SpriteFrame?
function SpriteAnimationUpdater:getCurrentSprite()
  if not self:isPlaying() then
    return nil
  end

  local spriteFrames = self.currentAnimation:getSpriteFrames(self.substripKey)
  if #spriteFrames == 0 then
    return nil
  end

  return spriteFrames[self.currentFrameIndex]
end

--- depends on indices updated in SpriteAnimationUpdater:update()
--- 
--- Returned function takes entity as argument
---@return function?
function SpriteAnimationUpdater:getCurrentAction()
  if not self:isPlaying() then
    return nil
  end

  return self.currentAnimation:getTimedActions(self.substripKey)[self.currentFrameIndex]
end

SpriteAnimationUpdater.States = States
return SpriteAnimationUpdater
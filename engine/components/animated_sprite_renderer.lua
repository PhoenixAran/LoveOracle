local Class = require 'lib.class'
local SpriteRenderer = require 'engine.components.sprite_renderer'

local States = {
  None = 0,
  Running = 1,
  Paused = 2,
  Completed = 3
}

---@class AnimatedSpriteRenderer : SpriteRenderer
---@field state integer
---@field animations table<any, SpriteAnimation>
---@field substripKey integer
---@field currentAnimationKey string
---@field currentAnimation SpriteAnimation
---@field currentFrameIndex integer
---@field currentTick integer
---@field loopType string
local AnimatedSpriteRenderer = Class { __includes = SpriteRenderer,
  --init = function(self, entity, animations, defaultAnimation, offsetX, offsetY, followZ, enabled, visible)
  init = function(self, entity, args)
    if args.offsetX == nil then args.offsetX = 0 end
    if args.offsetY == nil then args.offsetY = 0 end
    if args.followZ == nil then args.followZ = true end
    assert(args.animations)
    assert(args.defaultAnimation)
    self.state = States.None
    self.animations = args.animations
    self.substripKey = nil
    self.currentAnimationKey = args.defaultAnimation
    self.currentAnimation = self.animations[args.defaultAnimation]
    self.currentFrameIndex = 1
    self.currentTick = 1
    self.loopType = 'once'
    -- setup args table for SpriteRenderer
    local spriteFrames = self.currentAnimation:getSpriteFrames()
    args.sprite = spriteFrames[1]:getSprite()
    SpriteRenderer.init(self, entity, args)
  end
}

function AnimatedSpriteRenderer:getType()
  return 'animated_sprite_renderer'
end

function AnimatedSpriteRenderer:isPlaying()
  return self.state == States.Running
end

function AnimatedSpriteRenderer:isCompleted()
  return self.state == States.Completed
end

function AnimatedSpriteRenderer:getCurrentAnimationKey()
  return self.currentAnimationKey
end

function AnimatedSpriteRenderer:getSubstripKey()
  return self.substripKey
end

-- replays the current animation with the current substrip key
function AnimatedSpriteRenderer:setSubstripKey(value)
  if self.substripKey ~= value then
    self.substripKey = value
    if self.state ~= States.Paused then
      self:play(self.currentAnimationKey, value)
    end
  end
end

---play given animation. If no arguments are given, it just continues the current animation
---@param animation string?
---@param substripKey integer?
---@param forcePlayFromStart boolean?
function AnimatedSpriteRenderer:play(animation, substripKey, forcePlayFromStart)
  if forcePlayFromStart == nil then forcePlayFromStart = false end
  local playFromStart = forcePlayFromStart
  if animation ~= nil then
    playFromStart = playFromStart or self.currentAnimationKey ~= animation
    self.currentAnimationKey = animation
    self.currentAnimation = self.animations[animation]
    assert(self.currentAnimation, 'Animation: ' .. animation .. ' does not exist')
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

function AnimatedSpriteRenderer:isAnimationActive(name)
  return self.currentAnimation ~= nil and self.currentAnimationKey == name
end

function AnimatedSpriteRenderer:pause()
  self.state = States.Paused
end

-- should probably make play method varidic to achieve this idk
function AnimatedSpriteRenderer:unPause()
  return self.state == States.Running
end

function AnimatedSpriteRenderer:stop()
  -- no need to set these to nil im pretty sure?
  --self.currentAnimation = nil
  --self.currentAnimationKey = nil
  self.currentFrameIndex = 1
  self.currentTick = 1
  self.state = States.None
end

function AnimatedSpriteRenderer:update(dt)
  if not self:isPlaying() then
    return
  end
  local timedActions = self.currentAnimation:getTimedActions(self.substripKey)
  local spriteFrames = self.currentAnimation:getSpriteFrames(self.substripKey)
  local timedAction = timedActions[self.currentFrameIndex]
  if timedAction then
    timedAction(self.entity)
  end
  -- some animation can have no spriteframes and just action frames
  if #spriteFrames == 0 then return end
  local currentFrame = spriteFrames[self.currentFrameIndex]
  self.currentTick = self.currentTick + 1
  if currentFrame:getDelay() < self.currentTick then
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
  self:setSprite(currentFrame:getSprite())
end

return AnimatedSpriteRenderer
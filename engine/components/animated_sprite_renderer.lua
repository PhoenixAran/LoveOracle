local Class = require 'lib.class'
local Component = require 'lib.entity.component'

local States = { 
  None = 0, 
  Running = 1,
  Paused = 2,
  Completed = 3
}

local AnimatedSpriteRenderer = Class { __includes = Component,
  init = function(self)
    Component.init(self)
    self.state = States.None
    self.animations = { }
    self.currentAnimation = nil
    self.currentAnimationKey = nil
    self.currentFrameIndex = 1
    self.currentTick = 1
    self.loopType = 'once'
  end
}

function AnimatedSpriteRenderer:isPlaying()
  return self.state == States.Running
end

function AnimatedSpriteRenderer:play(animation)
  self.currentAnimation = self.animations[animation]
  self.currentAnimationKey = animation
  self.currentFrameIndex = 1
  self.currentTick = 1
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
  self.currentAnimation = nil
  self.currentAnimationKey = nil
  self.currentFrameIndex = 1
  self.state = States.None
end

function AnimatedSpriteRenderer:update(dt)
  if not self:isPlaying() then return end
  local timedAction = self.currentAnimation.timedActions[self.currentTick]
  if timedAction then 
    timedAction(self.entity) 
  end
  -- some animation can have no spriteframes and just action frames
  if #self.currentAnimation.spritesFrames == 0 then return end
  
  local currentFrame = self.currentAnimation.spriteFrames[self.currentFrameIndex]
  self.currentTick = self.currentTick + 1
  -- add one to delay since our indices start at 1
  if self.currentFrame.delay + 1 <= self.currentTick then
    self.currentTick = 1
    self.currentFrameIndex = self.currentFrameIndex + 1
    if self.loopType == 'once' then
      self.state = States.Completed
      self.currentFrameIndex = 0
    elseif self.loopType == 'cycle' then
      self.currentFrameIndex = 1
    end
    self.currentFrame = self.currentAnimation.spriteFrames[self.currentFrameIndex]
  end
  self:setSprite(self.currentFrame.sprite)
end

return AnimatedSpriteRenderer
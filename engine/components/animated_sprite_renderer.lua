local Class = require 'lib.class'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local Component = require 'engine.entities.component'

local States = { 
  None = 0, 
  Running = 1,
  Paused = 2,
  Completed = 3
}

local AnimatedSpriteRenderer = Class { __includes = SpriteRenderer,
  init = function(self, animations, defaultAnimation, offsetX, offsetY, enabled, visible)
    self.state = States.None
    self.animations = animations
    self.currentAnimationKey = defaultAnimation
    self.currentAnimation = animations[defaultAnimation]
    self.currentFrameIndex = 1
    self.currentTick = 1
    self.loopType = 'once'
    
    -- caveat is that the initial animation HAS to have a SpriteFrame and not just timed actions
    SpriteRenderer.init(self, self.currentAnimation.spriteFrames[1].sprite, offsetX, offsetY, enabled, visible)
    self:play(defaultAnimation)
  end
}

function AnimatedSpriteRenderer:getType()
  return 'animatedspriterenderer'
end

function AnimatedSpriteRenderer:isPlaying()
  return self.state == States.Running
end

function AnimatedSpriteRenderer:play(animation)
  self.currentAnimation = self.animations[animation]
  self.currentAnimationKey = animation
  self.currentFrameIndex = 1
  self.currentTick = 1
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
  if #self.currentAnimation.spriteFrames == 0 then return end
  
  local currentFrame = self.currentAnimation.spriteFrames[self.currentFrameIndex]
  self.currentTick = self.currentTick + 1
  -- add one to delay since our indices start at 1
  if currentFrame.delay + 1 <= self.currentTick then
    self.currentTick = 1
    self.currentFrameIndex = self.currentFrameIndex + 1
    if #self.currentAnimation.spriteFrames < self.currentFrameIndex then
      if self.loopType == 'once' then
        self.state = States.Completed
        self.currentFrameIndex = 0
      elseif self.loopType == 'cycle' then
        self.currentFrameIndex = 1
        currentFrame = self.currentAnimation.spriteFrames[self.currentFrameIndex]
      end
    end
  end
  self:setSprite(currentFrame.sprite)
end

return AnimatedSpriteRenderer
local Class = require 'lib.class'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local SpriteAnimationUpdater = require 'engine.graphics.sprite_animation_updater'
local States = SpriteAnimationUpdater.States


---@class AnimatedSpriteRenderer : SpriteRenderer
---@field spriteAnimationUpdater SpriteAnimationUpdater
---@field animations table<any, SpriteAnimation>
---@field currentAnimationKey string
local AnimatedSpriteRenderer = Class { __includes = SpriteRenderer,
  --init = function(self, entity, animations, defaultAnimation, offsetX, offsetY, followZ, enabled, visible)
  init = function(self, entity, args)
    if args.offsetX == nil then args.offsetX = 0 end
    if args.offsetY == nil then args.offsetY = 0 end
    if args.followZ == nil then args.followZ = true end
    assert(args.animations)
    assert(args.defaultAnimation)
    self.animations = args.animations
    self.currentAnimationKey = args.defaultAnimation
    self.spriteAnimationUpdater = SpriteAnimationUpdater()
    self.spriteAnimationUpdater:setSubstripKey(args.substripKey)
    -- setup args table for SpriteRenderer
    local spriteFrames = self.animations[self.currentAnimationKey]:getSpriteFrames()
    args.sprite = spriteFrames[1]:getSprite()
    SpriteRenderer.init(self, entity, args)
  end
}

function AnimatedSpriteRenderer:getType()
  return 'animated_sprite_renderer'
end

function AnimatedSpriteRenderer:getCurrentAnimationKey()
  return self.currentAnimationKey
end

function AnimatedSpriteRenderer:isPlaying()
  return self.spriteAnimationUpdater:isPlaying()
end

function AnimatedSpriteRenderer:isCompleted()
  return self.spriteAnimationUpdater:isCompleted()
end

function AnimatedSpriteRenderer:getSubstripKey()
  return self.spriteAnimationUpdater:getSubstripKey()
end

function AnimatedSpriteRenderer:setSpeed(speed)
  self.speed = math.min(0, speed)
end

function AnimatedSpriteRenderer:getSpeed()
  return self.speed
end

-- replays the current animation with the current substrip key
function AnimatedSpriteRenderer:setSubstripKey(value)
  self.spriteAnimationUpdater:setSubstripKey(value)
  if self:isPlaying() then
    self:play(self.currentAnimationKey, value, true)
  end
end

---play given animation. If no arguments are given, it just continues the current animation
---@param animation string?
---@param substripKey integer?
---@param forcePlayFromStart boolean?
function AnimatedSpriteRenderer:play(animation, substripKey, forcePlayFromStart)
  if forcePlayFromStart == nil then
     forcePlayFromStart = false
  end
  if animation ~= nil then
    self.currentAnimationKey = animation
    self.currentAnimation = self.animations[animation]
    assert(self.currentAnimation, 'Animation: ' .. animation .. ' does not exist')
    self.spriteAnimationUpdater:play(self.currentAnimation, substripKey, forcePlayFromStart)
  end
end

function AnimatedSpriteRenderer:isAnimationActive(name)
  return self.currentAnimation ~= nil and self.currentAnimationKey == name
end

function AnimatedSpriteRenderer:pause()
  return self.spriteAnimationUpdater:pause()
end

function AnimatedSpriteRenderer:stop()
  self.spriteAnimationUpdater:stop()
end

function AnimatedSpriteRenderer:update()
  local spriteFrame, timedAction = self.spriteAnimationUpdater:update()
  if timedAction then
    timedAction(self.entity)
  end
  if spriteFrame then
    self:setSprite(spriteFrame:getSprite())
  end
end

return AnimatedSpriteRenderer
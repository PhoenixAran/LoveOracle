local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local SpriteAnimationUpdater = require 'engine.graphics.sprite_animation_updater'
local Movement = require 'engine.components.movement'
-- TODO handle sound when the time comes

---@class EffectEntity : Entity
---@field effectAnimation SpriteAnimation the effect animation
---@field spriteAnimationUpdater SpriteAnimationUpdater the effect animation updater
---@field time number|nil the time in ms the effect should last. This will override the effectAnimation duration if provided
---@field effectSound any the effect sound
---@field movement Movement used for effects that bounce off ground
local EffectEntity = Class{ __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)
    self.currentTime = 0
    self.effectAnimation = args.effectAnimation
    self.time = args.time
    self.effectSound = args.sound
    self.movement = Movement()


  end
}

function EffectEntity:setVector(x, y)
  self.movement:setVector(x, y)
end

function EffectEntity:setZVelocity(value)
  self.movement:setZVelocity(value)
end

function EffectEntity:setGravity(value)
  self.movement:setGravity(value)
end

function EffectEntity:onAwake()
  if self.effectAnimation then
    self.spriteAnimationUpdater = SpriteAnimationUpdater()
    self.spriteAnimationUpdater:play(self.effectAnimation)
  end
  if self.effectSound then
    self.effectSound:play()
  end
end

function EffectEntity:update()
  local effectEnded = false
  if self.time then
    -- convert delta time to ms
    local ms = love.time.dt * 1000
    self.currentTime = self.currentTime + ms
    effectEnded = self.currentTime >= self.time
  end

  if self.spriteAnimationUpdater then
    self.spriteAnimationUpdater:update()
    effectEnded = effectEnded or self.spriteAnimationUpdater:isCompleted()
  end

  if effectEnded then
    self:destroy()
  end
end

function EffectEntity:draw()
  if self.spriteAnimationUpdater then
    local spriteFrame = self.spriteAnimationUpdater:getCurrentSprite()
    if spriteFrame then
      local x, y = self:getPosition()
      spriteFrame:getSprite():draw(x, y)
    end
  end
end

function EffectEntity:getType()
  return 'effect_entity'
end

return EffectEntity
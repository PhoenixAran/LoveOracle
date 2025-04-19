local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local SpriteAnimationUpdater = require 'engine.graphics.sprite_animation_updater'

-- TODO handle sound when the time comes

---@class EffectEntity : Entity
---@field effectAnimation SpriteAnimation the effect animation
---@field spriteAnimationUpdater SpriteAnimationUpdater the effect animation updater
---@field effectSound any the effect sound
local EffectEntity = Class{ __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)
    self.effectAnimation = args.effectAnimation
    self.effectSound = args.sound
  end
}

function EffectEntity:awake()
  if self.effectAnimation then
    self.spriteAnimationUpdater = SpriteAnimationUpdater()
    self.spriteAnimationUpdater:play(self.effectAnimation)
  end
  if self.effectSound then
    self.effectSound:play()
  end
end

function EffectEntity:update()
  if self.spriteAnimationUpdater then
    self.spriteAnimationUpdater:update()
    if self.spriteAnimationUpdater:isCompleted() then
      -- TODO: remove the effect entity
      self:destroy()
    end
  end
end

function EffectEntity:getType()
  return 'effect_entity'
end

return EffectEntity
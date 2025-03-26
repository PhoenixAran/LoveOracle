local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'

-- TODO handle sound when the time comes

---@class EffectEntity : Entity
---@field animation SpriteAnimation the effect animation
---@field sound any the effect sound
local EffectEntity = Class{ __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)
    self.effectAnimation = args.effectAnimation
    self.effectSound = args.sound
  end
}

function EffectEntity:update()

end

function EffectEntity:getType()
  return 'effect_entity'
end

return EffectEntity
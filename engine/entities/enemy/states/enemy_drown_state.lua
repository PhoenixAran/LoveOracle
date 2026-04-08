local Class = require 'lib.class'
local EnemyState = require 'engine.entities.enemy.states.enemy_state'
local EffectFactory = require 'engine.entities.effect_factory'

---@class EnemyDrownState : EnemyState
local EnemyDrownState = Class { __includes = EnemyState,
  init = function(self, enemy)
    EnemyState.init(self, enemy)
  end
}

function EnemyDrownState:beginState()
  if self.enemy:isInLava() then
    self.enemy:onFallInLava()
  else
    self.enemy:onFallInWater()
  end
  self.enemy:destroy()
end

function EnemyDrownState:getType()
  return 'enemy_drown_state'
end

function EnemyDrownState:free()
  EnemyState.free(self)
end

return EnemyDrownState
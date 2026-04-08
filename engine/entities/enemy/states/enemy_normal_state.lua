local Class = require 'lib.class'
local EnemyState = require 'engine.entities.enemy.states.enemy_state'

---@class EnemyNormalState : EnemyState
local EnemyNormalState = Class { __includes = EnemyState,
  init = function(self, args)
    EnemyState.init(self, args)
  end
}

function EnemyNormalState:update()
  self.enemy:updateAi()
end

function EnemyNormalState:getType()
  return 'enemy_normal_state'
end

function EnemyNormalState:free()
  EnemyState.free(self)
end


return EnemyNormalState
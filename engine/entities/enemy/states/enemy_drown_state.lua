local Class = require 'lib.class'
local EnemyState = require 'engine.entities.enemy.states.enemy_state'
local Pool = require 'engine.utils.pool'

local EnemyDrownState = Class { __includes = EnemyState,
  init = function(self, enemy)
    EnemyState.init(self, enemy)
    self.effect = nil
  end
}

function EnemyDrownState:getType()
  return 'enemy_drown_state'
end


function EnemyDrownState:update()
  
end

function EnemyDrownState:free()
  EnemyState.free(self)
end

Pool.register('enemy_drown_state', EnemyDrownState)

return EnemyDrownState
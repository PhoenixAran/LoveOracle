local Pool = require 'engine.utils.pool'
local Class = require 'lib.class'

local EnemyFallInHoleState = Class {
  init = function(self, enemy)

  end
}

function EnemyFallInHoleState:getType()
  return 'enemy_fall_in_hole_state'
end

function EnemyFallInHoleState:update()
  
end

Pool.register('enemy_fall_in_hole_state', EnemyFallInHoleState)

return EnemyFallInHoleState
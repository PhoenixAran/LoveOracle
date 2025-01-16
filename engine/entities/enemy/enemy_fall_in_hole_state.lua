local Class = require 'lib.class'
local vec2 = require 'lib.vector'
local lume = require 'lib.lume'

local EnemyFallInHoleState = Class {
  init = function(self, enemy)

  end
}

function EnemyFallInHoleState:getType()
  return 'enemy_fall_in_hole_state'
end

function EnemyFallInHoleState:update()
  
end

return EnemyFallInHoleState
local Class = require 'lib.class'

---@class EnemyState
local EnemyState = Class {
  init = function(self, enemy)
    self.enemy = enemy
  end
}

function EnemyState:update()
  
end

function EnemyState:getType()
  return 'enemy_state'
end
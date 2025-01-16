local Class = require 'lib.class'

local EnemyState = Class {
  init = function(self, enemy)
    self.enemy = enemy
  end
}



function EnemyState:getType()
  return 'enemy_state'
end
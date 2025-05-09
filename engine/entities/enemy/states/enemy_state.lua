local Class = require 'lib.class'

---@class EnemyState : SignalObject
---@field enemy BasicEnemy
local EnemyState = Class {
  init = function(self)
  end
}

function EnemyState:getType()
  return 'enemy_state'
end

function EnemyState:setEnemy(enemy)
  self.enemy = enemy
end

function EnemyState:beginState()
end

function EnemyState:update()
end

function EnemyState:endState()

end

function EnemyState:free()
  self.enemy = nil
end

return EnemyState
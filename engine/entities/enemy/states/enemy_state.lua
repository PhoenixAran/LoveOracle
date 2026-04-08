local Class = require 'lib.class'

---@class EnemyState : SignalObject
---@field enemy Enemy
local EnemyState = Class {
  init = function(self)
    self.enemy = nil 
  end
}

function EnemyState:getType()
  return 'enemy_state'
end

---@param enemy Enemy
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
local Class = require 'lib.class'

---@class EnemyState : SignalObject
---@field enemy BasicEnemy
---@field slipSpeed number
local EnemyState = Class {
  init = function(self)
    self.slipSpeed = 20
  end
}

function EnemyState:getType()
  return 'enemy_state'
end

function EnemyState:setEnemy(enemy)
  self.enemy = enemy
end

function EnemyState:beginState()
  local sprite = self.enemy.sprite
  if sprite.setSpeed then
    sprite:setSpeed(0.5)
  end
  
  -- TODO make other entities not colide with this one
end

function EnemyState:update()
  if not self.enemy:isInHole() then
    
  end
end

function EnemyState:endState()

end

function EnemyState:free()
  self.enemy = nil
  self.slipSpeed = 20
end

return EnemyState
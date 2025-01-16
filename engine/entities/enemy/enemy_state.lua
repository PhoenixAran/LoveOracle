local Class = require 'lib.class'

---@class EnemyState : SignalObject
---@field enemy BasicEnemy
---@field slipSpeed number
local EnemyState = Class {
  init = function(self, enemy)
    self.enemy = enemy

    self.slipSpeed = 20
  end
}

function EnemyState:getType()
  return 'enemy_state'
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


return EnemyState
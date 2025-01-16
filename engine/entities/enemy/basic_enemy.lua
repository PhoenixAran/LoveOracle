local Class = require 'lib.class'
local Enemy = require 'engine.entities.enemy'

--- Class with built in behaviour for enemies.
--- This class automatically handles entities:
--- >falling in hole, lava, and/or water
--- >Stun State
---@class BasicEnemy : Enemy
---@field state EnemyState?
local BasicEnemy = Class { __includes = Enemy,
  init = function(self, args)
    Enemy.init(self, args)

    -- inner state machine 
    self.state = nil

    -- environment configuration
    self.canFallInHole = false
    self.canSwimInLava = false
    self.canSwimInWater = false -- note this is only for deep water
  end
}

function BasicEnemy:getType()
  return 'basic_enemy'
end

---@param state EnemyState
function BasicEnemy:changeState(state)
  if self.state then
    self:onStateEnd(state)
    state:endState()
  end
  self:onStateBegin(state)
end

function BasicEnemy:update()
  if self.state then
    self.state:update()
  else
    self:updateAi()
  end
end

function BasicEnemy:beginNormalState()
  self.state = nil
end

-- this is where custom enemy code should be implemented in child classes
function BasicEnemy:updateAi()

end

---@param state EnemyState
function BasicEnemy:onStateEnd(state)

end

---@param state EnemyState
function BasicEnemy:onStateBegin(state)

end

---@param state EnemyState
function BasicEnemy:onStateUpdate(state)

end

return BasicEnemy
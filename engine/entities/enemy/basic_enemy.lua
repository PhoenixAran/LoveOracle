local Class = require 'lib.class'

local Enemy = require 'engine.entities.enemy'

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
    self:onUpdate()
  end
end

-- callbacks for enemy scripts
function BasicEnemy:onUpdate()

end

function BasicEnemy:onStateEnd(state)

end

function BasicEnemy:onStateBegin(state)

end

function BasicEnemy:onStateUpdate(state)

end

return BasicEnemy
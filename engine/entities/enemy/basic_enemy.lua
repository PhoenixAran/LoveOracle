local Class = require 'lib.class'
local vec2 = require 'lib.vector'
local lume = require 'lib.lume'

local Enemy = require 'engine.entities.enemy'

---@class BasicEnemy : Enemy
---@field state EnemyState?
local BasicEnemy = Class { __includes = Enemy,
  init = function(self, args)
    Enemy.init(self, args)
    self.state = nil
  end
}

function BasicEnemy:getType()
  return 'basic_enemy'
end

function BasicEnemy:update()
  if self.state then
    self.state:update()
  else
    self:onUpdate()
  end
end

function BasicEnemy:onUpdate()

end

return BasicEnemy
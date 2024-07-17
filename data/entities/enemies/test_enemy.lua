local Class = require 'lib.class'
local Enemy = require 'engine.entities.enemy'

local TestEnemy = Class { __includes = Enemy,
  init = function(self, args)
    Enemy.init(self, args)
    self.state = 'pick'
  end
}

function TestEnemy:getType()
  return 'test_enemy'
end

function TestEnemy:update()
  
end


return
local Class = require 'lib.class'
local Projectile require 'engine.entities.projectile.projectile'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'

local Arrow = Class { __includes = Projectile,
  init = function(self, args)
    -- Initialization code here
    
  end
}

function Arrow:onAwake()
  Projectile.onAwake(self)
  self.sprite:play('shoot')
end

function Arrow:getType()
  return 'arrow'
end

return Arrow


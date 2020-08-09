local Class = require 'lib.class'
local Vector = require 'lib.vector'
local Entity = require 'entity'

--[[
  The GameEntity class is what most entities will derive from.
  It includes more actions out of the box than the plain Entity class, at the cost
  of including default components
]]

local GameEntity = Class { __includes = Entity,
  init = function(self)
    
  end
}



function GameEntity:move(motionX, motionY, filter)
  
end


return GameEntity
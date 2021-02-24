local Class = require 'lib.lume'
local lume = require 'lib.lume'

--TODO: Entity Layer. Don't know what I want from this as of right now'
local EntityLayer = Class {
  init = function(self, data)
    
  end
}

function EntityLayer:getType()
  return 'entity_layer'
end


return EntityLayer
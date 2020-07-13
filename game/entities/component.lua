local Class = require 'lib.class'
local Transform = require 'lib.transform'
local Vector = require 'lib.vector'

local Component = Class {
  init = function(self, enabled, visible)
    if enabled == nil then enabled = true end
    if visible == nil then visible = true end
    
    self.entity = nil
    self.enabled = enabled
    self.visible = visible
  end
}

function component:getType()
  return 'component'
end

function Component:added(entity)
  self.entity = entity
end

return Component
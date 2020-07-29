local Class = require 'lib.class'
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

function Component:getType()
  return 'component'
end

function Component:isEnabled()
  return self.enabled
end

function Component:isVisible()
  return self.visible
end

function Component:added(entity)
  self.entity = entity
end

function Component:removed(entity)
  self.entity = nil
end

return Component
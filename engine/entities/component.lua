local Class = require 'lib.class'
local Vector = require 'lib.vector'
local SignalObject = require 'engine.signal_object'

local Component = Class { __includes = SignalObject,
  init = function(self, enabled, visible)
    SignalObject.init(self)
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

function Component:transformChanged()
  --local px, py = self.entity:getPosition()
  --self.x = x
  --self.y = y
end

function Component:isEnabled()
  return self.enabled
end

function Component:setEnabled(enabled)
  self.enabled = enabled
  if enabled then
    self:onEnabled()
  else 
    self:onDisabled()
  end
end

function Component:isVisible()
  return self.visible
end

function Component:entityAwake()
end

function Component:onEnabled()
end

function Component:onDisabled()
end

function Component:added(entity)
  self.entity = entity
  self:onAdded()
end

function Component:onAdded()
end

function Component:removed(entity)
  self.entity = nil
  self:onRemoved(entity)
end

function Component:onRemoved(entity)
end

return Component
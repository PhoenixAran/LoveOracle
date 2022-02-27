local Class = require 'lib.class'
local Vector = require 'lib.vector'
local SignalObject = require 'engine.signal_object'

local Component = Class { __includes = SignalObject,
  init = function(self, entity, args)
    SignalObject.init(self)
    if args.enabled == nil then args.enabled = true end
    if args.visible == nil then args.visible = true end
    self.entity = entity
    self.enabled = args.enabled
    self.visible = args.visible
  end
}

function Component:getType()
  return 'component'
end

function Component:transformChanged()
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

function Component:setVisible(value)
  self.visible = value
end

function Component:entityAwake()
end

function Component:onEnabled()
end

function Component:onDisabled()
end

function Component:entityRemoved()

end

return Component
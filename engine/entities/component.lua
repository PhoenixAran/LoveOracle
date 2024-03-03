local Class = require 'lib.class'
local Vector = require 'engine.math.vector'
local SignalObject = require 'engine.signal_object'

---@class Component : SignalObject
---@field entity Entity
---@field enabled boolean
---@field visible boolean
local Component = Class { __includes = SignalObject,
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
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

---Called when owner entity's transform is changed
function Component:transformChanged()
end

---if the component is enabled
---@return boolean enabled
function Component:isEnabled()
  return self.enabled
end

---enable or disable the component
---@param enabled boolean
function Component:setEnabled(enabled)
  self.enabled = enabled
  if enabled then
    self:onEnabled()
  else
    self:onDisabled()
  end
end

---returns if the component is visible
---@return boolean visible
function Component:isVisible()
  return self.visible
end

---sets if the component is visible
---@param value boolean
function Component:setVisible(value)
  self.visible = value
end

---called when the entity is awaken
function Component:entityAwake()
end

---called when the component is enabled
function Component:onEnabled()
end

---called when the component is disabled
function Component:onDisabled()
end

---called when the entity is removed
function Component:entityRemoved()
end

return Component
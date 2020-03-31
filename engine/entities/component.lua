local class = require 'lib.class'
local Transform = require 'lib.transform'
local Vector2 = require 'lib.vec2'

local Component = class {
  init = function(self, enabled, visible)
    if enabled == nil then
      enabled = false
    end

    if visible == nil then
      visible = false
    end
    self.transform = Transform.new()
    self.enabled = enabled
    self.visible = visible
  end
}

function getType()
  return 'component'
end

function Component:setEntity(entity)
  self.entity = entity
  self.transform:setParent(entity.transform)
end

--transform passthroughs
function Component:setPosition(x, y)
  self.transform:setPosition(x, y)
end

function Component:getPosition()
  local x, y = self.transform:getPosition()
  return x, y
end

function Component:setLocalPosition(x, y)
  self.transform:setLocalPosition(x, y)
end

function Component:getLocalPosition()
  local x, y = self.transform:getLocalPosition()
  return x, y
end

return Component

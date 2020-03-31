local class = require 'lib.class'

local ComponentList = class {
  init = function(self)
    self.components = { }
  end
}

function ComponentList:addComponent(component)
  self.components[#self.components + 1] = component
end

function ComponentList:removeComponent(component)
  local indexPosition = 0
  for index, value in ipairs(self.componentList) do
    if value == component then
      indexPosition = index
      break
    end
  end
  self.componentList.remove(indexPosition)
end

function ComponentList:entityAwake()
  for _, component in ipairs(self.components) do
    if component.entityAwake then
      component:entityAwake()
    end
  end
end

function ComponentList:entityRemoved()
  for _, component in ipairs(self.components) do
    if component.entityRemoved then
      component:entityRemoved()
    end
  end
end

function ComponentList:update(dt)
  for _, component in ipairs(self.components) do
    if component.update and component.enabled then
      component:update(dt)
    end
  end
end

function ComponentList:draw()
  for _, component in ipairs(self.components) do
    if component.draw and component.visible then
      component:draw()
    end
  end
end

function ComponentList:debugDraw(debugDraw)
  for _, component in ipairs(self.components) do
    if component.debugDraw then
      component:debugDraw()
    end
  end
end

return ComponentList

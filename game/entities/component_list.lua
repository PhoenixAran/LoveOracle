local Class = require 'lib.class'
local lume = require 'lib.lume'

local LockModes = { 
  Open = 1, 
  Locked = 2,
  Error = 3
}

-- list helper functions
local function containsValue(table, val)
   for i=1,#table do
      if table[i] == val then 
         return true
      end
   end
   return false
end

local function removeValue(table, val)
  local indexPosition = 0
  for index, value in ipairs(table) do
    if value == val then
      indexPosition = index
      break
    end
  end
  table.remove(indexPosition)
end

local ComponentList = Class {
  init = function(self, entity)
    self.entity = entity
    self.lockMode = LockModes.Open
    
    -- lists
    self.components = { }
    self.drawableComponents = { }
    self.toAdd = { }
    self.toRemove = { }
    
    -- hashsets
    self.current = { }
    self.adding = { }
    self.removing = { }
  end
}

function ComponentList:getType()
  return "componentlist"
end

-- notify components that the entity transform has changed
function ComponentList:transformChanged()
  for _, component in ipairs(self.components) do
    if component.transformChanged ~= nil then
      component:transformChanged()
    end
  end
end

function ComponentList:entityAwake()
  for _, component in ipairs(self.components) do
    if component.entityAwake ~= nil then
      component:entityAwake()
    end
  end
end

function ComponentList:setLockMode(lockmode) 
  self.lockMode = value
  if #self.toAdd > 0 then
    for _, component in ipairs(self.toAdd) do
      if not self.current[component] then
        self.current[component] = true
        self.components[#self.components + 1] = component
        if component.draw ~= nil then
          self.drawableComponents[#self.drawableComponents + 1] = component
        end
      end
    end
    lume.clear(self.adding)
    lume.clear(self.toAdd)
  end
  
  if #self.toRemove > 0 then
    for _, component in ipairs(self.toRemove) do
      if self.current[component] then
        self.current.remove(component)
        removeValue(self.current, component)
        if component.draw ~= nil then
          self.drawableComponents.remove(component)
        end
      end
    end
    lume.clear(self.removing)
    lume.clear(self.toRemove)
  end
end

function ComponentList:add(component)
  if self.lockMode == LockModes.Open then
    if not self.current[component] then
      self.current[component] = true
      self.components[#self.components + 1] = component
      if component.draw ~= nil then
        self.drawableComponents[#self.drawableComponents + 1] = component
      end
      component:added(self.entity)
    end
  elseif self.lockMode == LockModes.Locked then
    if not self.current[component] and containsValue(self.adding, component) then
      removeValue(self.adding, component)
      self.toAdd[component] = true
    end
  else
    error("Cannot add or remove components at this time")
  end
end

function ComponentList:remove(component)
  if self.lockMode == LockModes.Open then
    if self.current[component] then
      self.current.remove(component)
      removeValue(self.components, component)
      if component.draw ~= nil then
        removeValue(self.drawableComponents, component)
      end
      component:removed(self.entity)
    end
  elseif self.lockMode == LockModes.Locked then
    if self.current[component] and containsValue(self.removing, component) then
      self.removing[#self.removing + 1] = component
      self.toRemove[component] = true
    end
  else
    error("Cannot add or remove components at this time")
  end
end

function ComponentList:update(dt)
  self:setLockMode(LockModes.Locked)
  for _, component in ipairs(self.components) do
    if component:isEnabled() and component.update ~= nil then
      component:update(dt)
    end
  end
  self:setLockMode(LockModes.Open)
end

function ComponentList:draw()
  self:setLockMode(LockModes.Error)
  for _, component in ipairs(self.drawableComponents) do
    if component:isVisible() then
      component:draw()
    end
  end
  self:setLockMode(LockModes.Open)
end

function ComponentList:debugDraw()
  self:setLockMode(LockModes.Error)
  for _, component in ipairs(self.components) do
    if component.debugDraw ~= nil then
      component:debugDraw()
    end
  end
  self:setLockMode(LockModes.Open)
end

function ComponentList:getComponent(typeName)
  for _, component in ipairs(self.components) do
    if component:getType() == typeName then
      return component
    end
  end
  return nil
end

return ComponentList
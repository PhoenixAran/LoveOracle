local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local SignalObject = require 'engine.signal_object'

---@class EntityTracker : SignalObject
---@field entities Entity[]
---@field maxCount integer
local EntityTracker = Class {
  init = function(self, maxCount)
    if maxCount == nil then
      maxCount = math.huge
    end
    -- Initialization code here
    SignalObject.init(self)
    self.entities = { }
    self.maxCount = maxCount
  end
}

---@param entity Entity
---@return boolean
function EntityTracker:addEntity(entity)
  if entity.destroyed then
    return false
  end
  if lume.count(self.entities) >= self.maxCount then
    return false
  end

  lume.push(self.entities, entity)
  entity:connect('entity_destroyed', self, 'onEntityDestroyed')
  return true
end

---@param entity Entity
function EntityTracker:remove(entity)
  entity:disconnect('entity_destroyed', self)
  lume.remove(self.entities, entity)
end

function EntityTracker:clear()
  for _, entity in ipairs(self.entities) do
    entity:disconnect('entity_destroyed', self)
  end
  lume.clear(self.entities)
end

---@param entity Entity
function EntityTracker:onEntityDestroyed(entity)
  -- Don't call entity:disconnect() here.
  -- The entity is already calling :release(), which will 
  -- handle the disconnection for us safely.
  lume.remove(self.entities, entity)
end

function EntityTracker:isMaxedOut()
  return lume.count(self.entities) >= self.maxCount
end

function EntityTracker:isEmpty()
  return lume.count(self.entities) == 0
end

function EntityTracker:isAvailable()
  return not self:isMaxedOut()
end

function EntityTracker:release()
  SignalObject.release(self)
  self:clear()
end

return EntityTracker
local Class = require 'lib.class'
local EntityBank = require 'engine.banks.entity_bank'
local lume = require 'lib.lume'

local InstanceId = 0
local function getInstanceId()
  InstanceId = InstanceId + 1
  return InstanceId - 1
end

--- flattens the properties field in tiled objects and makes it part of the main table
--- this is so game code does not have to know how Tiled editor lays out it's json format
--- { x = 20, y = 33, properties : { customX : 5}} -> { x = 20, y = 33, customX : 5}
local function flattenArgs(args)
  local flattenedArgs = lume.clone(args)
  local customProperties = flattenedArgs.properties
  if customProperties then
    flattenedArgs.properties = nil
    for k, v in pairs(customProperties) do
      if k ~= 'type' then
        flattenedArgs[k] = v
      end
    end
  end
  return flattenedArgs
end

---@class EntitySpawner
---@field id integer Id for entity spawner. Used in rooms for keeping track of entity spawns (see entity spawn flags)
---@field entityClass string
---@field constructorArgs table
local EntitySpawner = Class {
  init = function(self, args)
    self.id = getInstanceId()
    if not (args.properties and args.properties.scriptType) then
      love.log.error('Cannot find spawnType property in ' .. love.inspect(args, {depth = 2}))
      error('Could not create entity spawner for object without "spawnType" field')
    end
    self.entityClass = args.properties.scriptType
    self.constructorArgs = flattenArgs(args)
    -- this messes with our entity constructor. 
    -- we nil this out so our constructor knows to generate one for an entity with an empty name provided
    if self.constructorArgs.name == "" then
      self.constructorArgs.name = nil
    end
  end
}

function EntitySpawner:getType()
  return 'entity_spawner'
end

---@return Entity
function EntitySpawner:createEntity()
  return EntityBank.createEntity(self.entityClass, self.constructorArgs)
end

return EntitySpawner
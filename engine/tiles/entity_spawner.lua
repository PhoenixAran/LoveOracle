local Class = require 'lib.class'
local EntityBank = require 'engine.banks.entity_bank'
local lume = require 'lib.lume'

local InstanceId = 0
local function getInstanceId()
  InstanceId = InstanceId + 1
  return InstanceId - 1
end

---convert bottomleft coordinate to topleft
local function convertTileCoordsToBumpCoords(x,y,w,h)
  if x == nil then
    return nil, nil
  end
  if w == nil then
    return x, y
  end
  return x, y - h
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
  flattenedArgs.x, flattenedArgs.y = convertTileCoordsToBumpCoords(args.x, args.y, args.width, args.height)
  return flattenedArgs
end

---@class EntitySpawner
---@field id integer Id for entity spawner. Used in rooms for keeping track of entity spawns (see entity spawn flags)
---@field entityClass string
---@field constructorArgs table
local EntitySpawner = Class {
  init = function(self, args)
    self.id = getInstanceId()
    self.entityClass = args.type
    self.constructorArgs = flattenArgs(args)
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
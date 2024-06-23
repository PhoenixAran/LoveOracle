local Class = require 'lib.class'
local EntityBank = require 'engine.banks.entity_bank'
local lume = require 'lib.lume'

--- flattens the properties field in tiled objects and makes it part of the main table
local function flattenArgs(args)
  local flattenedArgs = lume.clone(args)
  local customProperties = flattenedArgs.properties
  if customProperties then
    for k, v in pairs(customProperties) do
      if k ~= 'class' then
        flattenedArgs[k] = v
      end
    end
  end
  return flattenedArgs
end

---@class EntitySpawner
---@field constructorArgs table
local EntitySpawner = Class {
  init = function(self, args)
    self.entityType = args.class
    self.constructorArgs = flattenArgs(args)
  end
}

function EntitySpawner:getType()
  return 'entity_spawner'
end

---@return Entity
function EntitySpawner:spawnEntity()
  return EntityBank.makeEntity(self.entityType, self.constructorArgs)
end

return EntitySpawner
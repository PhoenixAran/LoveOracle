local lume = require 'lib.lume'
local fh = require 'engine.utils.file_helper'
local parse = require 'engine.utils.parse_helpers'
-- we don't want to register any entity base classes or any non entity classes into the db
local excludedEntities = {
  -- skip core files
  'bump_box',
  'component',
  'damage_info',
  'enemy',
  'entities',
  'entity',
  'inspector_properties',
  'map_entity',
  'transform',

  -- skip entities that get manually created map_loader.lua
  'room_edge'
}
---database of entity constructors. used in the maploader class
---@class EntityBank
---@field entities table<string, function>
local EntityBank = {
  entities = { }
}

local function registerEntity(requirePath)
  local strSplit = parse.split(requirePath, '%.')
  local entityKey = strSplit[lume.count(strSplit)]:sub(1, -1) -- remove the % from the escaped character
  assert(EntityBank.entities[entityKey] == nil, 'Entity "' .. entityKey .. '" already registered')
  EntityBank.entities[entityKey] = require(requirePath)
end

local function loadEntities(directory)
  local luaFiles = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(luaFiles) do
    local path = directory .. '/' .. file
    if love.filesystem.getInfo(path).type == 'directory' then
      loadEntities(path)
    else
      -- load the entity
      local entityName = fh.getFileNameWithoutExtension(path)
      if not lume.find(excludedEntities, entityName) then
        assert(not EntityBank.entities[entityName], 'Duplicate entity script ' .. path)
        local requirePath = fh.getFilePathWithoutExtension(path):gsub('/', '.')
        registerEntity(requirePath)
      end
    end
  end
end

function EntityBank.initialize(path)
  love.log.trace('Initializing entity bank')

  -- load entities from our core engine
  registerEntity('engine.entities.moving_platform')
  registerEntity('engine.entities.ledge_jump')

  -- load entities from our data folder
  loadEntities('data/entities')
end

function EntityBank.createEntity(entityKey, args)
  local entityConstructor = EntityBank.entities[entityKey]
  assert(entityConstructor ~= nil, 'Entity ' .. entityKey .. ' not in entity bank')
  return entityConstructor(lume.clone(args))
end

return EntityBank
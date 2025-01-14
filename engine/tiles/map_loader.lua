local lume = require 'lib.lume'
local TiledMapLoader = require 'engine.tiles.tiled.tiled_map_loader'
local TileData = require 'engine.tiles.tile_data'
local Tileset = require 'engine.tiles.tileset'
local TileLayer = require 'engine.tiles.tile_layer'
local MapData = require 'engine.tiles.map_data'
local LayerTileset = require 'engine.tiles.layer_tileset'
local RoomData = require 'engine.tiles.room_data'
local Constants = require 'constants'
local EntitySpawner = require 'engine.tiles.entity_spawner'



---@type table<string, Tileset>
local tilesetCache = { }
---@type table<string, MapData>
local mapCache = { }
local GRID_SIZE = require('constants').GRID_SIZE

---@class MapLoader
local MapLoader = { }

---@param mapData MapData
---@param tiledMapLayer TiledTileLayer
local function makeTileLayer(mapData, tiledMapLayer)
  local tileLayer = TileLayer()
  tileLayer.width = tiledMapLayer.width
  tileLayer.height = tiledMapLayer.height
  for _, gid in ipairs(tiledMapLayer.tiles) do
    lume.push(tileLayer.tiles, gid)
  end
  lume.push(mapData.tileLayers, tileLayer)
end

---@param mapData MapData
---@param tiledMapLayer TiledObjectLayer
local function makeRooms(mapData, tiledMapLayer)
  local roomDatas = { }
  for _, tiledObj in ipairs(tiledMapLayer.objects) do
    local roomData = RoomData()
    assert(tiledObj.x ~= nil and tiledObj.y ~= nil and tiledObj.width ~= nil
          and tiledObj.height ~= nil, 'Could not find values for x, y, width, height')
    -- lua index
    print(tiledObj.id, tiledObj.x, tiledObj.y, tiledObj.width, tiledObj.height)
    roomData.topLeftPosX = math.floor(tiledObj.x / GRID_SIZE) + 1
    roomData.topLeftPosY = math.floor(tiledObj.y / GRID_SIZE) + 1
    roomData.width = tiledObj.width / GRID_SIZE
    roomData.height = tiledObj.height / GRID_SIZE
    lume.push(mapData.rooms, roomData)
  end
  return roomDatas
end

---@param mapData MapData
---@param tiledMapLayer TiledObjectLayer
local function makePlayerSpawns(mapData, tiledMapLayer)
  assert(lume.count(tiledMapLayer.objects) <= 2, 'Too many test_spawn instances')
  local testSpawn = lume.first(lume.filter(tiledMapLayer.objects, function(x) return x.properties.spawnType == 'test' end))
  local gameSpawn = lume.first(lume.filter(tiledMapLayer.objects, function(x) return x.properties.spawnType == 'game' end))
  if testSpawn then
    mapData.testSpawnPositionX, mapData.testSpawnPositionY = testSpawn.x + GRID_SIZE / 2, testSpawn.y + GRID_SIZE / 2
  end
  if gameSpawn then
    mapData.initialSpawnPositionX, mapData.initialSpawnPositionY = gameSpawn.x, gameSpawn.y
  end
end

---@param map MapData
---@param x number
---@param y number
---@return RoomData?
local function getRoomDataContainingPosition(map, x, y)
  local tileIndexX = math.floor(x / GRID_SIZE) + 1
  local tileIndexY = math.floor(y / GRID_SIZE) + 1
  for _, roomData in ipairs(map.rooms) do
    if roomData.topLeftPosX <= tileIndexX and tileIndexX <= roomData.topLeftPosX + roomData.width
       and roomData.topLeftPosY <= tileIndexY and tileIndexY <= roomData.topLeftPosY + roomData.height then
        return roomData
      end
  end
  return nil
end

--- NB: this requires the rooms to have been made
---@param mapData MapData
---@param tiledMapLayer TiledObjectLayer
local function makeEntitySpawnersInRooms(mapData, tiledMapLayer)
  for _, obj in ipairs(tiledMapLayer.objects) do
    local roomData = getRoomDataContainingPosition(mapData, obj.x, obj.y)
    if roomData then
      lume.push(roomData.entitySpawners, EntitySpawner(obj))
    else
      love.log.error('Entity Spawner at (' .. tostring(obj.x) .. ', ' .. tostring(obj.y) .. ') not in a room')
    end
  end
end

---@param name string
---@return Tileset
function MapLoader.getTileset(name)
  if tilesetCache[name] then
    return tilesetCache[name]
  end
  local tiledTileset = TiledMapLoader.getTileset(name)
  local tileset = Tileset()
  tileset.name = tiledTileset.name
  for gid, tiledTilesetTile in pairs(tiledTileset.tiles) do
    local tileData = TileData(tiledTilesetTile)
    tileset.tiles[gid] = tileData
    if tileData.sprite:isAnimated() then
      lume.push(tileset.animatedTiles, tileData)
    end
  end

  tilesetCache[name] = tileset
  return tileset
end

-- NB: path will be relative to data/tiled/maps
---@param path string
---@return MapData
function MapLoader.loadMapData(path)
  if mapCache[path] then
    love.log.trace(string.format('Loading map %s from cache'), path)
    return mapCache[path]
  end
  love.log.trace(string.format('Loading map %s from disk', path))
  local tiledMapData = TiledMapLoader.loadMapData(path)
  local mapData = MapData()
  mapData.width = tiledMapData.width
  mapData.height = tiledMapData.height

  -- parse layer tilesets
  for _, tiledTileLayerTileset in ipairs(tiledMapData.tilesets) do
    local tileset = MapLoader.getTileset(tiledTileLayerTileset.tileset.name)
    local layerTileset = LayerTileset()
    layerTileset.tileset = tileset
    layerTileset.firstGid = tiledTileLayerTileset.firstGid
    lume.push(mapData.layerTilesets, layerTileset)
  end

  -- parse layers
  --[[ 
    Expected map format:
      1.playerspawn
      2.entities
      3.rooms
      4.top
      5.bottom
  ]]
  assert(lume.count(tiledMapData.layers) == 5, 'Unexpected layer count in ' .. path .. '. Expected 5, receieved mapdata with ' .. lume.count(tiledMapData.layers) .. ' layers')

  -- get tile layers
  local bottomTiledTileLayer = lume.first(lume.filter(tiledMapData.layers, function(x) return x:getType() == 'tiled_tile_layer' and x.name:lower() == 'bottom' end))
  assert(bottomTiledTileLayer, 'Bottom tile layer cannot be found')
  local topTiledTileLayer = lume.first(lume.filter(tiledMapData.layers, function(x) return x:getType() == 'tiled_tile_layer' and x.name:lower() == 'top' end))
  assert(topTiledTileLayer, 'Top tile layer cannot be found')

  -- get room layer
  local roomTiledLayer = lume.first(lume.filter(tiledMapData.layers, function(x) return x:getType() == 'tiled_object_layer' and x.name:lower() == 'rooms' end))
  assert(roomTiledLayer, 'Room object layer cannot be found')

  -- get entities layer
  local entitiesTiledLayer = lume.first(lume.filter(tiledMapData.layers, function(x) return x:getType() == 'tiled_object_layer' and x.name:lower() == 'entities' end))
  assert(entitiesTiledLayer, 'Entities object layer cannot be found')

  -- get playersspawn layer
  local playerSpawnTiledLayer = lume.first(lume.filter(tiledMapData.layers, function(x) return x:getType() == 'tiled_object_layer' and x.name:lower() == 'playerspawn' end))
  assert(playerSpawnTiledLayer, 'PlayerSpawn object layer cannot be found')
  mapCache[path] = mapData

  -- parse layers
  makeTileLayer(mapData, bottomTiledTileLayer)
  makeTileLayer(mapData, topTiledTileLayer)
  makeRooms(mapData, roomTiledLayer)
  makeEntitySpawnersInRooms(mapData, entitiesTiledLayer)
  makePlayerSpawns(mapData, playerSpawnTiledLayer)

  return mapData
end

return MapLoader
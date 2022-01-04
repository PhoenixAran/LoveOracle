local lume = require 'lib.lume'
local TiledMapLoader = require 'engine.tiles.tiled.tiled_map_loader'
local TileData = require 'engine.tiles.tile_data'
local Tileset = require 'engine.tiles.tileset'
local TileLayer = require 'engine.tiles.tile_layer'
local MapData = require 'engine.tiles.map_data'
local LayerTileset = require 'engine.tiles.layer_tileset'
local RoomData = require 'engine.tiles.room_data'

local tilesetCache = { }
local mapCache = { }

-- export type
local MapLoader = { }

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
function MapLoader.loadMapData(path)
  if mapCache[path] then
    return mapCache[path]
  end
  local tiledMapData = TiledMapLoader.loadMapData(path)
  local mapData = MapData()
  for _, tiledTileLayerTileset in ipairs(tiledMapData.tilesets) do
    local tileset = MapLoader.getTileset(tiledTileLayerTileset.tileset.name)
    local layerTileset = LayerTileset()
    layerTileset.firstGid = tiledTileLayerTileset.firstGid
    layerTileset.tileset = tileset
  end
  for _, layer in ipairs(tiledMapData.layers) do
    if layer:getType() == 'tiled_tile_layer' then
      local tileLayer = TileLayer()
      tileLayer.width = layer.width
      tileLayer.height = layer.height
      for _, gid in ipairs(layer.tiles) do
        lume.push(tileLayer.tiles, gid)
      end
      lume.push(mapData.tileLayers, tileLayer)
    elseif layer:getType() == 'tiled_object_layer' then
      if layer.name:lower() == 'rooms' then
        -- parse room data
        for _, tiledObj in ipairs(layer.objects) do
          local roomData = RoomData()
          assert(tiledObj.x ~= nil and tiledObj.y ~= nil and tiledObj.width ~= nil
                and tiledObj.height ~= nil)
          roomData.topLeftPosX = tiledObj.x
          roomData.topLeftPosY = tiledObj.y
          roomData.width = tiledObj.width
          roomData.height = tiledObj.height
          lume.push(mapData.rooms, roomData)
        end
      elseif layer.name:lower() == 'entities' then
        -- todo parse entities
      else
        error('Unsupported object layer name: ' .. layer.name:lower())
      end
    else
      error('Unsupported layer type: ' .. layer:getType())
    end
  end
  mapCache[path] = mapData
  return mapData
end

return MapLoader
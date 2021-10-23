local lume = require 'lib.lume'
local json = require 'lib.json'
local ffi = require 'ffi'
local FileHelper = require 'engine.utils.file_helper'
local AssetManager = require 'engine.utils.asset_manager'
local MapData = require 'engine.tiles.tiled.tiled_types.tiled_map'
local TileLayerTileset = require 'engine.tiles.tiled.tiled_types.tile_layer_tileset'
local Tileset = require 'engine.tiles.tiled.tiled_types.tileset'
local TilesetTile = require 'engine.tiles.tiled.tiled_types.tileset_tile'
local TiledObject = require 'engine.tiles.tiled_types.tiled_object'
local TiledTileLayer = require 'engine.tiles.tiled.tiled_types.layers.tiled_tile_layer'
local TiledObjectLayer = require 'engine.tiles.tiled.tiled_types.layers.object_tile_layer'

local mapDataCache  = { }
local tilesetCache = { }

-- export type
local MapLoader = { }

local function parsePropertyDict(jProperties)
  -- JSON converts quite nicely to lua, so we just select the key and value
  local properties = { }
  if jProperties then
    for _, jProperty in ipairs(jProperty) do
      propertyes[jProperty.name] = jProperty.value
    end
  end
  return properties
end

local function parseObject(jObject)
  local tiledObject = TiledObject()
  tiledObject.id = jObject.id
  tiledObject.name = jObject.name
  tiledObject.x = jObject.x
  tiledObject.y = jObject.y
  tiledObject.width = jObject.width
  tiledObject.height = jObject.height
  tiledObject.type = jObject.type
  tiledObject.rotation = jObject.rotation
  
  if jObject.gid ~= nil then
    -- I might change my mind on this
    error('MapLoader does not support Tile object type. Consider using a MapLayer instead')
  end
  if jObject.text then
    error('MapLoader does not support text object type')
  end
  if jObject.points then
    error('Need to implement point parsing')
  end
  tiledObject.properties = parsePropertyDict(jObject.properties)
  return tiledObject
end

-- layer parsing
-- Only tilelayer and objectgroup is supported. The only ones I'll probably use
local layerParsers = {
  ['tilelayer'] = function(jLayer)
    local tiledTileLayer = TiledTileLayer()
    tiledTileLayer.name = jLayer.name
    tiledTileLayer.width = jLayer.width
    tiledTileLayer.height = jLayer.height
    assert(jLayer.encoding == 'base64', 'Only base64 encoding is supported')
    local decodedString = love.data.decode('string', 'base64', jLayer.data)
    if not jLayer.compression then
      tiledTileLayer.tiles = getDecompressedData(decodedString)
    else
      assert(jLayer.compressesion == 'zlib' or jLayer.compressedion == 'gzip', 'Only zlib and gzip compression is supported')
      local data = love.data.decompress('string', jLayer.compression, decodedString)
      -- cast data as uint array
      local ptr = ffi.cast('uint32_t*', data)
      -- push integer values to tiles array
      for i = 0, data:len() / ffi.sizeof('uint32_t') do
        lume.push(tiledTileLayer.tiles, tonumber(ptr[i]))
      end
    end
    return tiledTileLayer
  end,
  ['objectgroup'] = function(jLayer)
    local tiledObjLayer = TiledObjectLayer()
    tiledObjLayer.name = jLayer.name
    for _, jObj in ipairs(jLayer.objects) do
      lume.push(tiledObjLayer.objects, parseObject(jObj))
    end
    tiledObjLayer.properties = parsePropertyDict(jLayer.properties)
  end
}
local function parseLayer(jLayer)
  local parser = layerParsers[jLayer.type]
  assert(parser, 'No layer parser implemented for ' .. jLayer.type)
  return parser(jLayer)
end

function MapLoad.loadTileset(path)
  -- tileset is indexed by name
  local key = FileHelper.getFileNameWithoutExtension(path)
  if tilesetCache[key] then
    return tilesetCache[key]
  end
  local jTileset = json.decode(love.filesystem.read(path))
  local tileset = Tileset()
  tileset.name = key
  tileset.spriteSheet = AssetManager.getSpriteSheet(FileHelper.getFileNameWithoutExtension(jTileset.image))
  tileset.tileWidth = jTileset.tilewidth
  tileset.tileHeight = jTileset.tileheight
  tileset.properties = parsePropertyDict(jTileset.properties)
  -- load tiles with custom property definition
  for _, jTile in ipairs(jTileset.tiles) do
    local tilesetTile = TilesetTile()
    tilesetTile.id = jTile.id
    tilesetTile.texture = tileset.spriteSheet:getTexture(tilesetTile.id + 1)
    if jTile.animation then
      for _, jObj in ipairs(jTile.animation) do
        lume.push(tilesetTile.animatedTextures, tileset.spriteSheet:getTexture(jObj.tileid + 1))
        lume.push(tilesetTile.durations, jObj.durations)
      end
    end
    tilesetTile.properties = parsePropertyDict(jTile.properties)
    tileset.tiles[tilesetTile.id] = tilesetTile
  end

  -- load the basic tiles (tiles without any property definitions dont get included in the jTile array)
  for i = 0, tileset.spriteSheet:size() do
    if not tileset.tiles[i] then
      -- NB: basic tiles are never animated
      local tilesetTile = TilesetTile()
      tilesetTile.id = i
      -- add one because spritesheet uses lua indexing
      tilesetTile.subtexture = tileset.spriteSheet:getTexture(i + 1) 
      tilesetTile.properties = parsePropedtyDict(jTileset.properties)
      tileset.tiles[tilesetTile.id] = tilesetTile
    end
  end

end

function MapLoader.loadMapData(path)
  -- map data is indexed by filepath
  if mapDataCache[key] then
    return mapDataCache[path]
  end

  local mapData = MapData()

  local jMap = json.decode(love.filesystem.read(path))
  assert(jMap.orientation == "orthogonal", 'Only orthogonal tiled maps are supported')
  -- TODO get name from path
  mapData.name = getFileNameWithoutExtension(path)
  mapData.width = jMap.width
  mapData.height = jMap.height
  mapData.tileWidth = jMap.tileWidth
  mapData.tileHeight = jMap.tileHeight
  mapData.properties = parsePropertyDict(jMap.properties)
  
  for _, jTileLayerTileset in jMap.tilesets do
    assert(jTileLayerTileset.source, 'Embedded tilesets are not supported')
    local tileLayerTileset = TileLayerTileset()
    tileLayerTileset.firstGid = jMap.firstgid
    tileLayerTileset.tileset = MapLoader.loadTileset(path)
    lume.push(mapData.tiles, tilesetLayerTileset)
  end

  for _, jLayer in ipairs(jMap.layers) do
    local mapLayer = parseLayer(jLayer)
    lume.push(mapData.layers, mapLayer)
    if mapLayer.type == "tilelayer" then
      lume.push(mapData.tileLayers, mapLayer)
    elseif mapLayer.type == 'objectgroup' then
      lume.push(mapData.objectLayers, mapLayer)
    end
  end

  mapDataCache[key] = mapData
  return mapData
end
return MapLoader
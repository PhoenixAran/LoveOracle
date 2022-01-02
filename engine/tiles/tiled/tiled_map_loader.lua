local lume = require 'lib.lume'
local json = require 'lib.json'
local ffi = require 'ffi'
local FileHelper = require 'engine.utils.file_helper'
local SpriteSheet = require 'engine.graphics.sprite_sheet'
local AssetManager = require 'engine.utils.asset_manager'
local TiledMapData = require 'engine.tiles.tiled.tiled_types.tiled_map_data'
local TileLayerTileset = require 'engine.tiles.tiled.tiled_types.tiled_tile_layer_tileset'
local TiledTileset = require 'engine.tiles.tiled.tiled_types.tiled_tileset'
local TiledTilesetTile = require 'engine.tiles.tiled.tiled_types.tiled_tileset_tile'
local TiledObject = require 'engine.tiles.tiled.tiled_types.tiled_object'
local TiledTileLayer = require 'engine.tiles.tiled.tiled_types.layers.tiled_tile_layer'
local TiledObjectLayer = require 'engine.tiles.tiled.tiled_types.layers.tiled_object_layer'

local tiledTilesetCache = { }
local tilesetCacheCreated = false

local tiledMapDataCache  = { }

-- export type
local TiledMapLoader = { }

local function parsePropertyDict(jProperties)
  -- JSON converts quite nicely to lua, so we just select the key and value
  local properties = { }
  if jProperties then
    for k, jProperty in ipairs(jProperties) do
      properties[jProperty.name] = jProperty.value
    end
  end
  return properties
end

local function parseObject(jObject, mapData)
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
    tiledObject.gid = jObject.gid
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

local function getDecompressedData(data)
  local tileGids = { }
  -- cast data as uint array
  local ptr = ffi.cast('uint32_t*', data)
  for i = 0, (data:len() / ffi.sizeof('uint32_t')) - 1 do
    lume.push(tileGids, tonumber(ptr[i]))
  end
  return tileGids
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
      assert(jLayer.compression == 'zlib' or jLayer.compression == 'gzip', 'Only zlib and gzip compression is supported')
      local data = love.data.decompress('string', jLayer.compression, decodedString)
      tiledTileLayer.tiles = getDecompressedData(data)
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

-- not exposed to public API.
-- They will need to call TiledMapLoader.initTilesets() to load all the tilesets into memory
local function loadTileset(path)
  -- tileset is indexed by name
  local key = FileHelper.getFileNameWithoutExtension(path)
  if tiledTilesetCache[key] then
    return tiledTilesetCache[key]
  end
  local jTileset = json.decode(love.filesystem.read(path))
  local tileset = TiledTileset()
  tileset.name = key
  -- man handle spritesheet caching. Dont want to have to define spritesheets in a .spritesheet file for every tileset if we can avoid it
  local spriteSheetKey = FileHelper.getFileNameWithoutExtension(jTileset.image)
  if not AssetManager.spriteSheetCache[spriteSheetKey] then
    local spriteSheet = SpriteSheet(AssetManager.getImage(spriteSheetKey), jTileset.tilewidth, jTileset.tileheight, jTileset.margin, jTileset.spacing)
    AssetManager.spriteSheetCache[spriteSheetKey] = spriteSheet
  end
  tileset.spriteSheet = AssetManager.getSpriteSheet(spriteSheetKey)
  tileset.tileWidth = jTileset.tilewidth
  tileset.tileHeight = jTileset.tileheight
  tileset.properties = parsePropertyDict(jTileset.properties)
  -- load tiles with custom property definition
  for _, jTile in ipairs(jTileset.tiles) do
    local tilesetTile = TiledTilesetTile()
    tilesetTile.id = jTile.id
    tilesetTile.texture = tileset.spriteSheet:getTexture(tilesetTile.id + 1)
    if jTile.animation then
      for _, jObj in ipairs(jTile.animation) do
        lume.push(tilesetTile.animatedTextures, tileset.spriteSheet:getTexture(jObj.tileid + 1))
        lume.push(tilesetTile.durations, jObj.duration)
      end
    end
    tilesetTile.properties = parsePropertyDict(jTile.properties)
    tileset.tiles[tilesetTile.id] = tilesetTile
  end

  -- load the basic tiles (tiles without any property definitions dont get included in the jTile array)
  for i = 0, tileset.spriteSheet:size() do
    if not tileset.tiles[i] then
      -- NB: basic tiles are never animated
      local tilesetTile = TiledTilesetTile()
      tilesetTile.id = i
      -- add one because spritesheet uses lua indexing
      tilesetTile.subtexture = tileset.spriteSheet:getTexture(i + 1)
      tilesetTile.properties = parsePropertyDict(jTileset.properties)
      tileset.tiles[tilesetTile.id] = tilesetTile
    end
  end
  tiledTilesetCache[key] = tileset
  return tileset
end

-- NB: path will be relative to data/tiled/maps
function TiledMapLoader.loadMapData(path)
  assert(tilesetCacheCreated, 'Call TiledMapLoader.initTilesets before you load maps')
  local pathPrefix = 'data/tiled/maps/'
  path = pathPrefix .. path
  -- map data is indexed by filepath
  if tiledMapDataCache[path] then
    return tiledMapDataCache[path]
  end

  local mapData = TiledMapData()
  local jMap = json.decode(love.filesystem.read(path))
  assert(jMap.orientation == "orthogonal", 'Only orthogonal tiled maps are supported')
  mapData.name = FileHelper.getFileNameWithoutExtension(path)
  mapData.width = jMap.width
  mapData.height = jMap.height
  mapData.tileWidth = jMap.tileWidth
  mapData.tileHeight = jMap.tileHeight
  mapData.properties = parsePropertyDict(jMap.properties)
  for _, jTileLayerTileset in ipairs(jMap.tilesets) do
    assert(jTileLayerTileset.source, 'Embedded tilesets are not supported')
    local tileLayerTileset = TileLayerTileset()
    tileLayerTileset.firstGid = jMap.firstgid
    tileLayerTileset.tileset = loadTileset(jTileLayerTileset.source)
    lume.push(mapData.tilesets, tileLayerTileset)
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
  tiledMapDataCache[path] = mapData
  return mapData
end

function TiledMapLoader.getTileset(name)
  assert(tiledTilesetCache[name], 'Tileset with name ' .. name .. ' does not exist')
  return tiledTilesetCache[name]
end

-- called in ContentControl
function TiledMapLoader.initializeTilesets(directory)
  if directory == nil then
    directory = 'data/tiled/tilesets'
  end
  local tilesetFiles = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(tilesetFiles) do
    local path = directory .. '/' .. file
    if love.filesystem.getInfo(path).type == 'directory' then
      TiledMapLoader.initializeTilesets(path)
    else
      loadTileset(path)
    end
  end
  tilesetCacheCreated = true
end

function TiledMapLoader.unload()
  tiledMapDataCache = { }
  tiledTilesetCache = { }
  tilesetCacheCreated = false
end

return TiledMapLoader
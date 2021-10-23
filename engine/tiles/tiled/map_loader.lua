local lume = require 'lib.lume'
local json = require 'lib.json'
local ffi = require 'ffi'
local FileHelper = require 'engine.utils.file_helper'
local AssetManager = require 'engine.utils.asset_manager'
local MapData = require 'engine.tiles.tiled.tiled_map'
local TileLayerTileset = require 'engine.tiles.tile_layer_tileset'
local Tileset = require 'engine.tiles.tiled.tileset'
local TilesetTile = require 'engine.tiles.tiled.tileset_tile'

local mapDataCache  = { }
local tilesetCache = { }

-- export type
local MapLoader = { }

local function getDecompressedData(data)
  assert(ffi)
  local d = { }
  local decoded = ffi.cast('uint32_t*', data)
  for i = 0, data:len() / ffi.sizeof('uint32_t') do
    lume.push(d, tonumber(decoded[i]))
  end
  return d
end


local function parsePropertyDict(jProperties)
  -- JSON converts quite nicely to lua, so we just select the key and value
  local properties = { }
  for _, jProperty in ipairs(jProperty) do
    propertyes[jProperty.name] = jProperty.value
  end
  return properties
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
  tileset.tileWidth = jTileset.tileWidth
  tileset.tileHeight = jTileset.tileHeight
  
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

  local jObj = json.decode(love.filesystem.read(path))
  assert(jObj.orientation == "orthogonal", 'Only orthogonal tiled maps are supported')
  -- TODO get name from path
  mapData.name = getFileNameWithoutExtension(path)
  mapData.width = jObj.width
  mapData.height = jObj.height
  mapData.tileWidth = jObj.tileWidth
  mapData.tileHeight = jObj.tileHeight
  mapData.properties = parsePropertyDict(jObj.properties)
  
  for _, jTileLayerTileset in jObj.tilesets do
    assert(jTileLayerTileset.source, 'Embedded tilesets are not supported')
    local tileLayerTileset = TileLayerTileset()
    tileLayerTileset.firstGid = jObj.firstgid
    tileLayerTileset.tileset = MapLoader.loadTileset(path)
    lume.push(mapData.tiles, tilesetLayerTileset)
  end

  -- TODO layers!



  -- testing base64 decode
  -- local jLayer = jObj.layers[1]
  -- local layer = { }
  -- assert(ffi, 'Compressed maps require LuaJIT FFI. \nPlease switch your interperator to LuaJIT or your Tile Layer Format')
  -- local fd = love.data.decode('string', 'base64', layer.data)
  -- if jLayer.compression then
  --   if layer.compression == 'zlib' then
  --     local data = love.data.decompress('string', 'zlib', fd)
  --   elseif layer.compression == 'gzip' then
  --     local data = love.data.decompress('string', 'gzip', fd)
  --   else
  --     error('Only zlib and gzip decompression is supported')
  --   end
  -- else
  --   layer.data = getDecompressedData(fd)
  -- end
end
return MapLoader
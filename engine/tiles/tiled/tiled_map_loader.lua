local lume = require 'lib.lume'
local json = require 'lib.json'
local ffi = require 'ffi'
local FileHelper = require 'engine.utils.file_helper'
local SpriteSheet = require 'engine.graphics.sprite_sheet'
local AssetManager = require 'engine.asset_manager'
local TiledMapData = require 'engine.tiles.tiled.tiled_types.tiled_map_data'
local TiledLayerTileset = require 'engine.tiles.tiled.tiled_types.tiled_tile_layer_tileset'
local TiledTileset = require 'engine.tiles.tiled.tiled_types.tiled_tileset'
local TiledTilesetTile = require 'engine.tiles.tiled.tiled_types.tiled_tileset_tile'
local TiledObject = require 'engine.tiles.tiled.tiled_types.tiled_object'
local TiledTileLayer = require 'engine.tiles.tiled.tiled_types.layers.tiled_tile_layer'
local TiledObjectLayer = require 'engine.tiles.tiled.tiled_types.layers.tiled_object_layer'


local TILE_CLASS_NAME = 'tile'
local tiledMapLoaderInitialized = false
local tiledClasses = { }
local tiledTilesetCache = { }
local tiledTemplates = { }
local tiledMapDataCache  = { }

-- export type
---@class TiledMapLoader
local TiledMapLoader = { }


---@param jProperties table
---@return table
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

---@param jObject table
---@return TiledObject
local function parseObject(jObject)
  local tiledObject = TiledObject()

  local templateProperties = nil

  tiledObject.id = jObject.id
  tiledObject.name = jObject.name
  tiledObject.x = jObject.x
  tiledObject.y = jObject.y
  tiledObject.width = jObject.width
  tiledObject.height = jObject.height
  tiledObject.type = jObject.type
  tiledObject.rotation = jObject.rotation
  if jObject.type then
    -- TODO
  end
  if jObject.template then
    -- if this is a templated object, inject the template object value properties into our json object
    local templateKey = FileHelper.getFileNameWithoutExtension(jObject.template)
    local template = tiledTemplates[templateKey]
    for k, v in pairs(template.object) do
      if k == 'properties' then
        -- handle this later
        templateProperties = parsePropertyDict(v)
      elseif tiledObject[k] == nil then
        -- inject value from template into tiled object if instance does not have data for given field
        tiledObject[k] = template.object[k]
      end
    end
    if template.tileset then
      -- get the tile custom properties from the tileset
      local tiledTileset = tiledTilesetCache[FileHelper.getFileNameWithoutExtension(template.tileset.source)]
      local tiledTilesetTile = tiledTileset:getTile(template.object.gid - template.tileset.firstgid)
      if templateProperties == nil then
        templateProperties = { }
      end
      templateProperties = lume.merge(parsePropertyDict(tiledTilesetTile.properties), tiledTilesetTile.properties)
    end
  end

  if jObject.gid ~= nil then
    tiledObject.gid = jObject.gid
  end
  if jObject.text then
    error('MapLoader does not support text object type yet')
  end
  if jObject.points then
    error('Point parsing not supported')
  end

  if templateProperties then
    tiledObject.properties = templateProperties
    local jObjectProperties = parsePropertyDict(jObject.properties)
    -- override template properties and/or add additional properties from object instance
    -- for k, v in pairs(jObjectProperties) do
    --   tiledObject.properties[k] = v
    -- end
    tiledObject.properties = lume.merge(tiledObject.properties, jObjectProperties)
  else
    -- no properties for template, just assign directly
    tiledObject.properties = parsePropertyDict(jObject.properties)
  end
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
    ---@type TiledTileLayer
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
    ---@type TiledObjectLayer
    local tiledObjLayer = TiledObjectLayer()
    tiledObjLayer.name = jLayer.name
    for _, jObj in ipairs(jLayer.objects) do
      lume.push(tiledObjLayer.objects, parseObject(jObj))
    end
    tiledObjLayer.properties = parsePropertyDict(jLayer.properties)
    return tiledObjLayer
  end
}

local function parseLayer(jLayer)
  local parser = layerParsers[jLayer.type]
  assert(parser, 'No layer parser implemented for ' .. jLayer.type)
  return parser(jLayer)
end

local function makeSpriteSheetTileset(key, jTileset)
 ---@type TiledTileset
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
  if jTileset.tiles then
    for _, jTile in ipairs(jTileset.tiles) do
      local tilesetTile = TiledTilesetTile()
      tilesetTile.id = jTile.id
      tilesetTile.subtexture = tileset.spriteSheet:getTexture(tilesetTile.id + 1)
      if jTile.animation then
        for _, jObj in ipairs(jTile.animation) do
          lume.push(tilesetTile.animatedTextures, tileset.spriteSheet:getTexture(jObj.tileid + 1))
          lume.push(tilesetTile.durations, jObj.duration)
        end
      end
      if jTile.type then
        tilesetTile.properties = lume.merge(tilesetTile.properties, tiledClasses[jTile.type])
      end
      -- override values that are unique from tiled class default
      tilesetTile.properties = lume.merge(tilesetTile.properties, parsePropertyDict(jTile.properties))
      -- register tiled_tile in tileset
      tileset.tiles[tilesetTile.id] = tilesetTile
    end
  end

  -- load the basic tiles (tiles without any property definitions dont get in cluded in the jTile array)
  -- as of right now this really only loads in the template tilesets. Tiles that get the tile class get a dedicated json value
  -- that gets parsed in the for loop above
  for i = 0, tileset.spriteSheet:size() - 1 do
    if not tileset.tiles[i] then
      -- NB: basic tiles are never animated
      local tilesetTile = TiledTilesetTile()
      tilesetTile.id = i
      -- add one because spritesheet uses lua indexing
      tilesetTile.subtexture = tileset.spriteSheet:getTexture(i + 1)
      tileset.tiles[tilesetTile.id] = tilesetTile
    end
  end

  return tileset
end

local function makeImageCollectionTileset(key, jTileset)
  -- TODO
end


-- not exposed to public API.
-- They will need to call TiledMapLoader.initTilesets() to load all the tilesets into memory
---@param path string
---@return TiledTileset
local function loadTileset(path)
  -- tileset is indexed by name
  local key = FileHelper.getFileNameWithoutExtension(path)
  if tiledTilesetCache[key] then
    return tiledTilesetCache[key]
  end
  ---@type table
  local jTileset = json.decode(love.filesystem.read(path))
  ---@type TiledTileset?
  local tileset = nil
  if jTileset.image then
    tileset = makeSpriteSheetTileset(key, jTileset)
  else
    tileset = makeImageCollectionTileset(key, jTileset)
  end
 
  tiledTilesetCache[key] = tileset
  return tileset
end


local function loadTemplate(path)
  local key = FileHelper.getFileNameWithoutExtension(path)
  if tiledTemplates[key] then
    return tiledTemplates[key]
  end

  local jTemplate = json.decode(love.filesystem.read(path))

  assert(jTemplate.type == 'template', 'Cannot parse template form non-template tiled object')

  local tiledTemplate = { }
  tiledTemplate.object = { }
  for k, v in pairs(jTemplate.object) do
    -- tiled likes to save the id of the object intance when you save it as a template
    -- dont know why it does this. We ignore the property
    if k ~= 'id' then
      -- note that we leave the property dictionary in it's array form [{type = <value>, name = 'name', value = <value>}, ...]
      -- This is due to us having to account for an object having it's own instance of properties that we have to parse
      -- see parseObject function
      tiledTemplate.object[k] = v
    end
  end
  if jTemplate.tileset then
    tiledTemplate.tileset = { }
    for k, v in pairs(jTemplate.tileset) do
      tiledTemplate.tileset[k] = v
    end
  end
  tiledTemplates[key] = tiledTemplate
  return tiledTemplate
end


---called in initialize order: 1
---gets any custom classes so we can inject properties into it's tiled object instances
---@param directory string
local function initializeTiledProject(directory)
  if directory == nil then
    directory = 'data/tiled/'
  end
  local files = love.filesystem.getDirectoryItems(directory)
  local tiledProjectExtension = 'tiled-project'
  local foundTiledProjectFile = false
  for _, file in ipairs(files) do
    if file:sub(#tiledProjectExtension) == tiledProjectExtension then
      foundTiledProjectFile = true
      local path = directory .. '/' .. file
      local projectJson = json.decode(love.filesystem.read(path))
      if projectJson.propertyTypes then
        for _, jProperties in ipairs(projectJson.propertyTypes) do
          if jProperties.type == 'class' then
            local tiledClassDefaultValues = { }
            for _, jMember in ipairs(jProperties.members) do
              tiledClassDefaultValues[jMember.name] = jMember.value
            end
            tiledClasses[jProperties.name] = tiledClassDefaultValues
          end
        end
      end
      break
    end
  end
  assert(foundTiledProjectFile, 'Could not find tiled-project file in ' .. directory)
  assert(tiledClasses[TILE_CLASS_NAME], 'Could not find tiled editor class ' .. TILE_CLASS_NAME)
end

-- called in initialize
-- order: 2
local function initializeTilesets(directory)
  if directory == nil then
    directory = 'data/tiled/tilesets'
  end
  local tilesetFiles = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(tilesetFiles) do
    local path = directory .. '/' .. file
    if love.filesystem.getInfo(path).type == 'directory' then
      initializeTilesets(path)
    else
      love.log.debug('Loading tileset from ' .. path)
      loadTileset(path)
    end
  end
end

-- called in initialize
-- order: 3
local function initializeTemplates(directory)
  if directory == nil then
    directory = 'data/tiled/templates'
  end
  local templateFiles = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(templateFiles) do
    local path = directory .. '/' .. file
    if love.filesystem.getInfo(path).type == 'directory' then
      initializeTemplates(path)
    else
      loadTemplate(path)
    end
  end
end

function TiledMapLoader.initialize(directory)
  tiledMapLoaderInitialized = true
  initializeTiledProject(directory)
  initializeTilesets(directory)
  initializeTemplates(directory)
end


function TiledMapLoader.unload()
  tiledMapDataCache = { }
  tiledTilesetCache = { }
  tiledClasses = { }
  tiledMapLoaderInitialized = false
end

-- NB: path will be relative to data/tiled/maps
---@param path string
---@return TiledMapData
function TiledMapLoader.loadMapData(path)
  assert(tiledMapLoaderInitialized, 'Make sure you initialize TiledMapLoader before loading maps')
  local pathPrefix = 'data/tiled/maps/'
  path = pathPrefix .. path
  -- map data is indexed by filepath
  if tiledMapDataCache[path] then
    return tiledMapDataCache[path]
  end
  ---@type TiledMapData
  local mapData = TiledMapData()
  ---@type table
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
    local tileLayerTileset = TiledLayerTileset()
    tileLayerTileset.firstGid = jTileLayerTileset.firstgid
    tileLayerTileset.tileset = loadTileset(jTileLayerTileset.source)
    lume.push(mapData.tilesets, tileLayerTileset)
  end
  for _, jLayer in ipairs(jMap.layers) do
    local mapLayer = parseLayer(jLayer)
    lume.push(mapData.layers, mapLayer)
    if mapLayer:getType() == 'tiled_tile_layer' then
      lume.push(mapData.tileLayers, mapLayer)
    elseif mapLayer:getType() == 'tiled_object_layer' then
      lume.push(mapData.objectLayers, mapLayer)
    end
  end
  tiledMapDataCache[path] = mapData
  return mapData
end

--- TODO not sure if this should be public
---@return TiledTileset
function TiledMapLoader.getTileset(name)
  assert(tiledTilesetCache[name], 'Tileset with name ' .. name .. ' does not exist')
  return tiledTilesetCache[name]
end

return TiledMapLoader
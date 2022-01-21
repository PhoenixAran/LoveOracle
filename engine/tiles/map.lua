local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'
local Room = require 'engine.tiles.room'
local MapLoader = require 'engine.tiles.map_loader'

local Map = Class { __includes = SignalObject,
  init = function(self, mapData)
    SignalObject.init(self)
    if type(mapData) == 'string' then
      mapData = MapLoader.loadMapData(mapData)
    end
    self.mapData = mapData
    self.name = mapData.name
    self.width = mapData.width
    self.height = mapData.height
    self.layerTilesets = mapData.layerTilesets
    self.tileLayers = mapData.tileLayers
    self.rooms = { }
    for _, roomData in ipairs(mapData.rooms) do
      lume.push(self.rooms, Room(self, roomData))
    end
  end
}

function Map:getType()
  return 'map'
end

-- returns tile data for tile at the given position
function Map:getTileData(x, y, layerIndex)
  -- tiled is column 
  if layerIndex == nil then
    layerIndex = 1
  end
  assert(1 <= layerIndex and layerIndex <= lume.count(self.tileLayers))
  local tileLayer = self.tileLayers[layerIndex]
  if y == nil then
    return tileLayer:getTile(x)
  end
  local index = (y - 1) * self.width + x
  local gid = tileLayer:getTileGid(index)
  if lume.count(self.layerTilesets) == 1 then
    return self.layerTilesets[1]:getTileData(gid)
  end
  for i = 2, lume.count(self.layerTilesets) do
    local setA = self.layerTilesets[i - 1]
    local setB = self.layerTilesets[i]
    if setA.firstGid <= gid and gid < setB.firstGid then
      return setA:getTileData(gid)
    end
  end
  return lume.last(self.layerTilesets):getTileData(gid)
end

return Map
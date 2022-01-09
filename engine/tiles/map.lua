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

return Map
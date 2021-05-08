local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'
local Room = require 'engine.tiles.room'
local MapData = require 'engine.tiles.map_data'

local Map = Class { __includes = SignalObject,
  init = function(self, mapData)
    if type(mapData) == 'string' then
      local path = 'data/maps/' .. mapData .. '.dat'
      local sdata, err = love.filesystem.read(path)
      mapData = MapData(lume.deserialize(sdata))
    end
    SignalObject.init(self)
    self.mapData = mapData
    self.name = mapData:getName()
    self.sizeX = mapData:getSizeX()
    self.sizeY = mapData:getSizeY()
    self.layerCount = mapData:getLayerCount()
    self.rooms = { }
    lume.each(mapData.rooms, function(roomData)
      lume.push(self.rooms, Room(self, roomData))
    end)
    self.layers = mapData.layers
  end
}

function Map:getType()
  return 'map'
end

function Map:getMapData()
  return self.mapData
end

function Map:getName()
  return self.name
end

function Map:getSize()
  return self.sizeX, self.sizeY
end

function Map:getSizeX()
  return self.sizeX
end

function Map:getSizeY()
  return self.sizeY
end

function Map:getLayerCount()
  return self.layerCount
end

function Map:getRooms()
  return self.rooms
end

function Map:getLayers()
  return self.layers
end

function Map:getLayer(layerIndex)
  return self.layers[layerIndex]
end

return Map
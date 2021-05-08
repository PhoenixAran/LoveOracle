local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'
local Room = require 'engine.tiles.room'

local Map = Class { __includes = SignalObject,
  init = function(self, mapData)
    SignalObject.init(self)
    self.mapData = mapData
    self.name = mapData:getName()
    self.sizeX = mapData:getSizeX()
    self.sizeY = mapData:getSizeY()
    self.layerCount = mapData:getLayerCount()
    self.rooms = { }
    lume.each(mapData.rooms, function(roomData)
      lume.push(self.rooms, Room(roomData))
    end)
    self.layers = mapData.layers
  end
}

function Map:getType()
  return 'map'
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

function MapData:getSizeY()
  return self.sizeY
end

function MapData:getLayerCount()
  return self.layerCount
end

function MapData:getRooms()
  return self.rooms
end

function MapData:getLayers()
  return self.layers
end

function MapData:getLayer(layerIndex)
  return self.layers[layerIndex]
end

return Map
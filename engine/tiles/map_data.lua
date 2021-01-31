local Class = require 'lib.class'

local MapData = Class {
  init = function(self, data)
    self.name = name
    self.sizeX = 24
    self.sizeY = 24
    self.layers = 2
    self.tiles = { }
  end
}

function MapData:getType()
  return 'map_data'
end

function MapData:getSerializableTable()
  return {
    self.name = name
    layers = self.layers,
    tiles = self.tiles
    sizeX = self.sizeX
    sizeY = self.sizeY
  }
end

return MapData
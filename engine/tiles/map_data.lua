local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require' engine.signal_object'


local MapData = Class {
  init = function(self, mapData)
    self.mapData = mapData

  end
}

function MapData:getType()
  return 'map_data'
end




return MapData
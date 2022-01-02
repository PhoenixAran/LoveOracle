local Class = require 'lib.class'

local MapData = Class {
  init = function(self)
    self.name = nil
    self.height = -1
    self.width = ''
    -- array of layer tilesets
    self.layerTilesets = { }
    -- array of tile layers
    self.tileLayers = { }
    -- array of rooms
    self.rooms = { }
  end
}

function MapData:getType()
  return 'map_data'
end

return MapData
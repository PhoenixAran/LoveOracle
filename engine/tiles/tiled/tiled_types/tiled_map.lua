local Class = require 'lib.class'
local lume = require 'lib.lume'

local TiledMap = Class {
  init = function(self)
    self.name = nil
    -- number of tile rows
    self.height = 0
    -- number of tile columns
    self.width = 0
    -- array of layers
    self.layers = { }
    -- custom properties
    self.properties = { }
    -- included tilesets
    self.tilesets = { }
    -- organized layers for ease of use
    self.tileLayers = { }
    self.objectLayers = { }
  end
}

function TiledMap:getType()
  return 'tiled_map'
end

return TiledMap
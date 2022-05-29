local Class = require 'lib.class'
local lume = require 'lib.lume'

---@class MapData
---@field name string
---@field height integer
---@field width integer
---@field layerTilesets LayerTileset[]
---@field tileLayers TileLayer[]
---@field rooms Room[]
local MapData = Class {
  init = function(self)
    self.name = nil
    self.height = -1
    self.width = -1
    -- array of layer tilesets
    self.layerTilesets = { }
    -- array of tile layers
    self.tileLayers = { }
    -- array of room data
    self.rooms = { }
  end
}

function MapData:getType()
  return 'map_data'
end

return MapData
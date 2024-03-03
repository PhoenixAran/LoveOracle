local Class = require 'lib.class'

---@class TiledTileLayer 
---@field name string?
---@field properties table
---@field width integer
---@field height integer
---@field tiles TiledTileLayerTile[]
local TiledTileLayer = Class {
  init = function(self)
    self.name = nil
    self.properties = { }

    -- width in tiles
    self.width = 0
    -- height in tiles
    self.height = 0
    self.tiles = { }
  end
}

function TiledTileLayer:getType()
  return 'tiled_tile_layer'
end

function TiledTileLayer:getTileWithGid(gid)
  for k, v in ipairs(self.tiles) do
    if v and v.gid == gid then
      return v
    end
  end
  return nil
end

return TiledTileLayer
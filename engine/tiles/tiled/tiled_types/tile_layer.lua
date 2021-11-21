local Class = require 'lib.class'

local TileLayer = Class {
  init = function(self)
    self.name = nil
    self.properties = { }
    -- width in tiles for this layer
    self.width = -1
    -- height in tiles for this layer
    self.height = -1
    -- array of tiles
    self.tiles = { }
  end
}

function TileLayer:getType()
  return 'tile_layer'
end

function TileLayer:GetTileWithGid(gid)
  for k, v in ipairs(self.tiles) do
    if v and v.gid == gid then
      return v
    end
  end
  return nil
end

return TileLayer
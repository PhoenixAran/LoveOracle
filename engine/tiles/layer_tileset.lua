local Class = require 'lib.class'

-- wrapper around tileset with an Offset Gid so maps can use
-- more than one tileset at the same time
---@class LayerTileset
---@field tileset Tileset
---@field firstGid integer
local LayerTileset = Class {
  init = function(self)
    self.tileset = nil
    self.firstGid = 0
  end
}

function LayerTileset:getType()
  return 'layer_tileset'
end

function LayerTileset:getTileData(gid)
  return self.tileset:getTileData(gid - self.firstGid)
end

return LayerTileset
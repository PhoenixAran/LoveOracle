local Class = require 'lib.class'

-- NB: I dont think this is used at all
-- wrapper around TilesetTile. Do not reuse this class, as each MapData instance has unique tile id mappings
---@class TiledTileLayerTile
---@field tileLayerTileset TiledTileLayerTileset
---@field gid integer
---@field x integer
---@field y integer
local TiledTileLayerTile = Class {
  init = function(self)
    self.tileLayerTileset = nil
    self.gid = -1
    self.x = -1
    self.y = -1
  end
}

function TiledTileLayerTile:getType()
  return 'tiled_tile_layer_tile'
end

function TiledTileLayerTile:getTile()
  if self.gid < 1 then
    return nil
  end
  return self.tileLayerTileset:getTile(self.gid)
end

return TiledTileLayerTile
local Class = require 'lib.class'

-- wrapper around TilesetTile. Do not reuse this class, as each MapData instance has unique tile id mappings
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
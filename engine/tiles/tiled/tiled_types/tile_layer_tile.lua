local Class = require 'lib.class'

-- wrapper around TilesetTile. Do not reuse this class, as each MapData instance has unique tile id mappings
local TileLayerTile = Class {
  init = function(self)
    self.tileLayerTileset = nil
    self.gid = -1
    self.x = -1
    self.y = -1
  end
}

function TileLayerTile:getTile()
  --No tile exists for Gid of 0 (Luckily for lua this works out just fine)
  if self.gid < 1 then
    return nil
  end
  return self.tileLayerTileset:getTile(gid)
end

function TileLayerTile:getType()
  return 'tile_layer_tile'
end

return TileLayerTile
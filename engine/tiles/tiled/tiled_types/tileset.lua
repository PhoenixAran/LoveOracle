local Class = require 'lib.class'

-- raw tileset data directly translated from json file. This requires the wrapper class TileLayerTileset for
-- tile id mappings. This class can be reused since it does not contain MapData specific values like 'firstGid'
local Tileset = Class {
  init = function(self)
    self.name = nil
    self.width = 0
    self.height = 0
    self.tileWidth = 0
    self.tileHeight = 0

    -- int, TilesetTile dictionary
    self.tiles = { }

    -- spritesheet used for tiles
    self.spriteSheet = nil
  end
}

function Tileset:getType()
  return 'tileset'
end

function Tileset:getTile(gid)
  return self.tiles[gid]
end

return Tileset
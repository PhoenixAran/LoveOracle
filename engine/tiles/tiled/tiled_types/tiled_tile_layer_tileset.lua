local Class = require 'lib.class'

--[[ 
   Maps in Tiled can have more than one tileset. To account for duplicate tile IDs, each tileset loaded
   will have an attribute called "firstgid." (always defaults to 1) This firstgid is an id offset to keep tile ids unique.
   Example, map has Tileset A and Tileset B. Tileset A has the default firstgid of 1 and Tileset B has first gid of 7
   Tile 1 will point to A[1 - A.firstgid]
   Tile 7 will point to B[7 - B.firstgid]
]]--
-- Wrapper around Tileset. Do not reuse cache this class, as each MapData instance has unique TileLayerTilesets
local TiledTileLayerTileset = Class {
  init = function(self, firstGid, tileset)
    self.firstGid = firstGid
    self.tileset = tileset
  end
}

function TiledTileLayerTileset:getType()
  return 'tile_layer_tileset'
end

function TiledTileLayerTileset:getTile(index)
  return self.tileset:getTile(index - self.firstGid)
end

return TiledTileLayerTileset
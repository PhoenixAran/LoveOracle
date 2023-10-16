local Class = require 'lib.class'

-- raw tileset data directly translated from json file. This requires the wrapper class TileLayerTileset for
-- tile id mappings. This class can be reused since it does not contain MapData specific values like 'firstGid'
---@class TiledTileset
---@field name string?
---@field width integer
---@field height integer
---@field tileWidth integer
---@field tileHeight integer
---@field tiles table<integer, TiledTilesetTile>
---@field spriteSheet SpriteSheet?
---@field properties table
local TiledTileset = Class {
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

    self.properties = { }
  end
}

function TiledTileset:getType()
  return 'tiled_tileset'
end

function TiledTileset:getTile(gid)
  return self.tiles[gid]
end

return TiledTileset
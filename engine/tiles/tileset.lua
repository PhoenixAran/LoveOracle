local Class = require 'lib.class'
local lume = require 'lib.lume'

---@class Tileset
---@field name string
---@field tiles TileData[]
---@field animatedTiles TileData[]
local Tileset = Class {
  init = function(self)
    self.name = nil
    -- indexed by Gid
    self.tiles = { }
    -- array of animated tiles. This is a dictionary of int, TileData
    -- the int is the TileData's InstanceId
    self.animatedTiles = { }
  end
}

function Tileset:getType()
  return 'tileset'
end

function Tileset:getTileData(gid)
  return self.tiles[gid]
end

-- set animated frame index to 0 for each animated tiles
function Tileset:resetTileSpriteAnimations()
  for _, tileData in ipairs(self.animatedTiles) do
    tileData.sprite:resetSpriteAnimation()
  end
end

return Tileset
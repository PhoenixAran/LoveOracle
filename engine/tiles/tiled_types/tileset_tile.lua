local Class = require 'lib.class'
local lume = require 'lib.lume'

-- Tile element in Tilesets. Requires wrapper class TileLayerTile for correct Tile mapping ids
-- Can be reused since it does not contain any MapData specific data
local TilesetTile = Class {
  init = function(self)
    self.id = -1
    self.type = nil
    self.width = 0
    self.height = 0

    self.subtexture = nil
    self.animatedTextures = nil
  end

}

function TilesetTile:getType()
  return 'tileset_tile'
end

function TilesetTile:isAnimated()
  if self.animatedTextures == nil then
    return false
  end
  return lume.count(animatedTextures) > 0
end

return TilesetTile
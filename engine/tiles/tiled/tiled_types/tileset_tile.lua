local Class = require 'lib.class'
local lume = require 'lib.lume'

-- Tile element in Tilesets. Requires wrapper class TileLayerTile for correct Tile mapping ids
-- Can be reused since it does not contain any MapData specific data
local TilesetTile = Class {
  init = function(self)
    self.id = -1
    self.subtexture = nil

    -- table of subtextures if it is animated
    self.animatedTextures = { }
    -- how long each animated texture lasts. Indices will be mapped 1 to 1 with animated textures
    self.durations = { }
    self.properties = { }
  end

}

function TilesetTile:getType()
  return 'tileset_tile'
end

function TilesetTile:isAnimated()
  if self.animatedTextures == nil then
    return false
  end
  return lume.count(self.animatedTextures) > 0
end

return TilesetTile
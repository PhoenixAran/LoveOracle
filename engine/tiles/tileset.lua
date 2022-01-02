local Class = require 'lib.class'
local lume = require 'lib.lume'

local Tileset = Class {
  init = function(self, tiledTileset)
    self.name = nil
    self.tiles = { }
  end
}

function Tileset:getType()
  return 'tileset'
end

function Tileset:getTileData(gid)
  return self.tiles[gid]
end

return Tileset
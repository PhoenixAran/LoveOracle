local Class = require 'lib.class'

local TileLayer = Class {
  init = function(self)
    -- tiledata Gids
    self.tiles = { }
    self.width = -1
    self.height = -1
  end
}

-- returns tile Gid
function TileLayer:getTileGid(x, y)
  if y == nil then
    return self.tiles[x]
  end
  return self.tiles[(y - 1) * self.width + x]
end

return TileLayer

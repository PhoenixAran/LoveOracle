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
  return self.tiles[(x - 1) * self.height + y]
end

return TileLayer

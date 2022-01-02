local Class = require 'lib.class'

-- wrapper around tileset with an Offset Gid so maps can use
-- more than one tileset at the same time
local LayerTileset = Class {
  init = function(self)
    self.tileset = nil
    self.firstGid = -1
  end
}

function LayerTileset:getType()
  return 'layer_tileset'
end

return LayerTileset
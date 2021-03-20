local Class = require 'lib.class'

local NIL_TABLE = { }

-- Layers
local TileLayer = Class {
  init = function(self, data)
    self.sizeX = data.sizeX
    self.sizeY = data.sizeY
    self.tiles = data.tiles or { }
  end
}

function TileLayer:getType()
  return 'tile_layer'
end

function TileLayer:setTile(tileData, x, y)
  if y == nil then
    self.tiles[x] = tileData
  else
    self.tiles[(x - 1) * self.sizeY + y] = tileData
  end
end

function TileLayer:getTile(x, y)
  if y == nil then
    return self.tiles[x]
  else
    return self.tiles[(x - 1) * self.sizeY + y]
  end
end

function TileLayer:getSerializableTable()
  return {
    layerType = self:getType(),
    sizeX = self.sizeX,
    sizeY = self.sizeY,
    tiles = self.tiles
  }
end

return TileLayer
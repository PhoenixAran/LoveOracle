local Class = require 'lib.class'
local lume = require 'lib.lume'

local MapData = Class {
  init = function(self)
    self.name = nil
    self.height = -1
    self.width = -1
    -- array of layer tilesets
    self.layerTilesets = { }
    -- array of tile layers
    self.tileLayers = { }
    -- array of room data
    self.rooms = { }
  end
}

function MapData:getType()
  return 'map_data'
end

-- returns tile data for tile at the given position
function MapData:getTile(x, y, layerIndex)
  if layerIndex == nil then
    layerIndex = 1
  end
  assert(1 <= layerIndex and layerIndex <= lume.count(self.tileLayers))
  local tileLayer = self.tileLayers[layerIndex]
  if y == nil then
    return tileLayer:getTile(x)
  end
  local index = (x - 1) * self.height + y
  local gid = tileLayer:getTile(x, y)
  if lume.count(self.layerTilesets) == 1 then
    return self.layerTilesets[1]:getTileData(gid)
  end
  for i = 2, lume.count(self.layerTilesets) do
    local setA = self.layerTilesets[i - 1]
    local setB = self.layerTilesets[i]
    if setA.firstGid <= gid and gid < setB.firstGid then
      return setA:getTileData(gid)
    end
  end
  return lume.last(self.layerTilesets):getTileData(gid)
end

return MapData
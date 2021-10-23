local Class = require 'lib.class'
local lume = require 'lib.lume'

local MapData = Class {
  init = function(self)
    self.width = 0
    self.height = 0
    self.tileWidth = 0
    self.tileHeight = 0
    self.layers = { }
    --NB: holds TileLayerTilesets, not source Tilesets
    self.tilesets = { }
    self.properties = { }
    -- organized layers for easy access
    self.tileLayers = { }
    self.objectLayers = { }
  end
}

function MapData:getType()
  return 'map_data'
end

function MapData:getTilesetForTileLayerGid(gid)
  local tilesetCount = lume.count(self.tilesets)
  assert(tilesetCount > 0)
  if tilesetCount == 1 then
    return tilesetCount[1]
  end
  for i = 2, tilesetCount do
    local setA = self.tilesets[i - 1]
    local setB = self.tilesets[i]
    if setA.firstGid <= gid and gid < setB.firstGid then
      return setA
    end
  end
  return self.tilesets[tilesetCount]
end

return MapData
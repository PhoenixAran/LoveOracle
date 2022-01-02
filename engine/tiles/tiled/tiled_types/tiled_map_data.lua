local Class = require 'lib.class'
local lume = require 'lib.lume'

local TiledMapData = Class {
  init = function(self)
    self.name = nil
    -- number of tile rows
    self.height = 0
    -- number of tile columns
    self.width = 0
    -- array of layers
    self.layers = { }
    -- custom properties
    self.properties = { }
    -- included tilesets
    self.tilesets = { }
    -- organized layers for ease of use
    self.tileLayers = { }
    self.objectLayers = { }
  end
}

function TiledMapData:getType()
  return 'tiled_map_data'
end

function TiledMapData:getTilesetForTileLayerGid(gid)
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

return TiledMapData
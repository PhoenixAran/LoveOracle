local SpatialHash = require 'engine.Physics.spatial_hash'
local lume = require 'lib.lume'

local Physics = { }

-- cell size when new spatial hash is created
local spatialHashCellSize = 64

-- spatial hash instance
local spatialHash = SpatialHash(specialHashCellSize)

function Physics.reset()
  spatialHash = SpatialHash(spatialHashCellSize)
end

function Physics.boxcastBroadphase(box, boundsX, boundsY, boundsW, boundsH)
  return spatialHash:aabbBroadphase(box, boundsX, boundsY, boundsW, boundsH)
end

function Physics.add(box)
  spatialHash:register(box)
end

function Physics.update(box)
  spatialHash:remove(box)
  spatialHash:register(box)
end

function Physics.remove(box)
  spatialHash:remove(box)
end

function Physics.linecast(startX, startY, endX, endY, hits, layerMask, zmin, zmax)
  return spatialHash:linecast(startX, startY, endX, endY, hits, layerMask, zmin, zmax)
end

return Physics
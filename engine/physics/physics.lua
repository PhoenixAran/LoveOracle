local SpatialHash = require 'engine.physics.spatial_hash'
local lume = require 'lib.lume'

local physics = { }

-- cell size when new spatial hash is created
local spatialHashCellSize = 100

-- spatial hash instance
local spatialHash = SpatialHash(specialHashCellSize)

-- allocation avoidance for overlap checks and shape casts
local colliderTable = { }

function physics.reset()
  spatialHash = SpatialHash(spatialHashCellSize)
  lume.clear(colliderTable)
end

function physics.boxcastBroadphase(box, boundsX, boundsY, boundsW, boundsH)
  return spatialHash:aabbBroadphase(box, boundsX, boundsY, boundsW, boundsH)
end

function physics.add(box)
  spatialHash:register(box)
end

function physics.update(box)
  spatialHash:remove(box)
  spatialHash:register(box)
end

function physics.remove(box)
  spatialHash:remove(box)
end

return physics
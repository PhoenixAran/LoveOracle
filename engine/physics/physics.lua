local SpatialHash = require 'engine.physics.spatial_hash'
local lume = require 'lib.lume'

local physics = { }

local spatialHash

-- cell size when new spatial hash is created
local spatialHashCellSize = 32

-- allocation avoidance for overlap checks and shape casts
local colliderTable = { }

function physics.reset()
  spatialHash = SpatialHash(spatialHashCellSize)
  lume.clear(colliderTable)
end

function physics.boxcastBroadphase(box, bounds)
  return SpatialHash:aabbBroadphase(bounds, box)
end

return physics
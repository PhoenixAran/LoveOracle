local SpatialHash = require 'engine.physics.spatial_hash'
local lume = require 'lib.lume'

local physics = { }

local spatialHash = SpatialHash()

-- cell size when new spatial hash is created
local spatialHashCellSize = 32

-- allocation avoidance for overlap checks and shape casts
local colliderTable = { }

function physics.reset()
  spatialHash = SpatialHash(spatialHashCellSize)
  lume.clear(colliderTable)
end

function physics.boxcastBroadphase(box, bounds)
  return spatialHash:aabbBroadphase(bounds, box)
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
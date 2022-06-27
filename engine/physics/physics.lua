local SpatialHash = require 'engine.physics.spatial_hash'
local lume = require 'lib.lume'

--note: BumpBoxes are annoted as any

--- Physics Module
local Physics = { }

-- cell size when new spatial hash is created
local spatialHashCellSize = 64

-- spatial hash instance
local spatialHash = SpatialHash(spatialHashCellSize)

function Physics.reset()
  spatialHash = SpatialHash(spatialHashCellSize)
end

---@param box any
---@param boundsX number
---@param boundsY number
---@param boundsW number
---@param boundsH number
---@return any[]
function Physics.boxcastBroadphase(box, boundsX, boundsY, boundsW, boundsH)
  return spatialHash:aabbBroadphase(box, boundsX, boundsY, boundsW, boundsH)
end

---register bumpbox into the physics system
---@param box any
function Physics.add(box)
  spatialHash:register(box)
end

---update BumpBox position in physics system
---@param box any
function Physics.update(box)
  spatialHash:remove(box)
  spatialHash:register(box)
end

---remove BumpBox from physics system
---@param box any
function Physics.remove(box)
  spatialHash:remove(box)
end

---perform rectangle cast in physics system
---@param x number
---@param y number
---@param w number
---@param h number
---@param hits table
---@param layerMask integer
---@param zmin integer
---@param zmax integer
---@return any[]
function Physics.rectcast(x, y, w, h, hits, layerMask, zmin, zmax)
  return spatialHash:rectcast(x, y, w, h, hits, layerMask, zmin, zmax)
end

---perform linecast in physics system
---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param hits table
---@param layerMask integer
---@param zmin number
---@param zmax number
---@return any[]
function Physics.linecast(startX, startY, endX, endY, hits, layerMask, zmin, zmax)
  return spatialHash:linecast(startX, startY, endX, endY, hits, layerMask, zmin, zmax)
end

---perform pointcast in physics system
---@param posX number
---@param posY number
---@param hits table
---@param layerMask integer
---@param zmin integer
---@param zmax integer
---@return any[]
function Physics.pointcast(posX, posY, hits, layerMask, zmin, zmax)
  return spatialHash:pointcast(posX, posY, hits, layerMask, zmin, zmax)
end

return Physics
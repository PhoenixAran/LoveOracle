local bit = require 'bit'
local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'

local RaycastResultParser = Class {
  init = function(self)
    self.hitCounter = 0
    
    self.hits = { }
    -- Parallel array to hits 
    self.distances = { }

    self.checkedBoxes = { }
    --self.cellHits = { }
    
    self.ray = {
      startX = 0,
      startY = 0,
      endX = 0,
      endY = 0,
      directionX = 0,
      directionY = 0
    }
    self.layerMask = 0
    self.zmin = math.mininteger
    self.zmax = math.maxinteger
  end
}

function RaycastResultParser:start(startX, startY, endX, endY, hits, layerMask, zmin, zmax)
  self.hits = hits
  self.layerMask = layerMask
  self.hitCounter = 1
  self.ray.startX = startX
  self.ray.startY = startY
  self.ray.endX = endX
  self.ray.endY = endY
  self.ray.directionX, self.ray.directionY = vector.sub(endX, endY, startX, startY)
  if zmin == nil then
    self.zmin = math.mininteger
  else
    self.zmin = zmin
  end
  if zmax == nil then
    self.zmax = math.maxinteger
  else
    self.zmax = zmax
  end
end

function RaycastResultParser:checkRayIntersection(cellX, cellY, cell)
  for i = 1, lume.count(cell) do
    local potential = cell[i]
    if not lume.find(self.checkedBoxes, potential) ~= nil then
      lume.push(self.checkedBoxes, potential)
      if bit.band(potential:getPhysicsLayer(), self.layerMask) ~= 0 then
        local px, py, pw, ph = potential:getBounds()
        local zmin, zmax = potential:getZRange()
        if self.zmax > zmin and self.zmin < self.zmax then
          local rayIntersects, fraction = rect.rayIntersects(px, py, pw, ph,self.ray.startX, self.ray.startY, self.ray.endX, self.ray.endY)
          if rayIntersects and fraction <= 1.0 then
            lume.push(self.hits, potential)
            lume.push(self.distances, vector.dist(px, py, self.ray.startX, self.ray.startY))
          end
        end
      end
    end
  end
  if lume.count(self.hits) > 0 then
    self:sortHits()
    --for i = 1, lume.count(self.cellHits) do
    --  self.hits[self.hitCounter] = self.cellHits[i]
    --end
    return true
  end
  return false
end

function RaycastResultParser:sortHits()
  for i = 1, lume.count(self.hits) - 1 do
    local ci = i 
    while true do
      local shouldSwap = false
      if self.distances[ci] > self.distances[ci + 1] then
        self.hits[ci], self.hits[ci + 1] = self.hits[ci + 1], self.hits[ci]
        self.distances[ci], self.distances[ci + 1] = self.distances[ci + 1], self.distances[ci]
        shouldSwap = true
      end
      if shouldSwap then
        ci = ci - 1
      else
        break
      end
    end
  end
end

function RaycastResultParser:reset()
  self.hits = nil
  lume.clear(self.checkedBoxes)
  --lume.clear(self.cellHits)
  self.zmin = math.mininteger
  self.zmax = math.maxinteger
  self.layerMask = -1
  self.hitCounter = 1
end

function RaycastResultParser:getType()
  return 'raycast_result_parser'
end

return RaycastResultParser
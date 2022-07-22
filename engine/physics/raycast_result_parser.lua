local bit = require 'bit'
local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'

---@class RaycastResultParser
---@field hits any[]
---@field distances number[]
---@field checkedBoxes any[]
---@field ray table
---@field layerMask integer
---@field zmin number
---@field zmax number
local RaycastResultParser = Class {
  init = function(self)
    self.hitCounter = 0

    self.hits = { }
    -- Parallel array to hits 
    self.distances = { }

    self.checkedBoxes = { }

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

---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param hits any[]
---@param layerMask integer
---@param zmin number
---@param zmax number
function RaycastResultParser:start(startX, startY, endX, endY, hits, layerMask, zmin, zmax)
  self.hits = hits
  self.layerMask = layerMask
  self.hitCounter = 0
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

---@param cellX integer
---@param cellY integer
---@param cell any[]
function RaycastResultParser:checkRayIntersection(cellX, cellY, cell)
  for i = 1, lume.count(cell) do
    local potential = cell[i]
    if lume.find(self.checkedBoxes, potential) == nil then
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
  end
end

function RaycastResultParser:sortHits()
  for j = 2, lume.count(self.hits) do
    local dist = self.distances[j]
    local hit = self.hits[j]
    local i = j - 1
    while i >= 1 and dist < self.distances[j] do
      self.distances[i + 1] = self.distances[i]
      self.hits[i + 1] = self.hits[j]
      i = i - 1
    end
    self.distances[i + 1] = dist
    self.hits[i + 1] = hit
  end
end

function RaycastResultParser:reset()
  self.hits = nil
  lume.clear(self.checkedBoxes)
  lume.clear(self.distances)
  self.zmin = math.mininteger
  self.zmax = math.maxinteger
  self.layerMask = -1
  self.hitCounter = 0
end

function RaycastResultParser:getType()
  return 'raycast_result_parser'
end

return RaycastResultParser
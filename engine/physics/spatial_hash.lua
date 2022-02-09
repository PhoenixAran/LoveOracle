local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local TablePool = require 'engine.utils.table_pool'
local RaycastResultParser = require 'engine.physics.raycast_result_parser'

-- helper math functions
local function sign(number)
  if number > 0 then
    return 1
  elseif number < 0 then
    return -1
  else
    return 0
  end
end

local function approach(startVal, endVal, shift)
  if startVal < endVal then
    return math.min(startVal + shift, endVal)
  end
  return math.max(startVal - shift, endVal)
end

local SpatialHash = Class {
  init = function(self, cellSize)
    if cellSize == nil then cellSize = 32 end
    
    self.cellSize = cellSize
    self.inverseCellSize = 1 / cellSize
    
    self.cellDict = { }
    
    self.gridBounds = { x = 0, y = 0, w = 0, h = 0 }
    self.overlapTestBox = { x = 0, y = 0, w = 0, h = 0 }

    self.raycastResultParser = RaycastResultParser()
  end
}

function SpatialHash:getType()
  return 'spatial_hash'
end

function SpatialHash:cellCoords(x, y)
  return math.floor(x * self.inverseCellSize), math.floor(y * self.inverseCellSize)
end

function SpatialHash:cellAtPosition(x, y)
  local cellRow = self.cellDict[x]
  if cellRow == nil then
    cellRow = { }
    cellRow[y] = { }
    self.cellDict[x] = cellRow
  end
  if cellRow[y] == nil then
    cellRow[y] = { }
  end
  return cellRow[y]
end

function SpatialHash:register(box)
  local bx, by, bw, bh = box:getBounds()  
  box.registeredPhysicsBounds.x = bx
  box.registeredPhysicsBounds.y = by
  box.registeredPhysicsBounds.w = bw
  box.registeredPhysicsBounds.h = bh

  local px1, py1 = self:cellCoords(bx, by)
  local px2, py2 = self:cellCoords(bx + bw, by + bh)  -- ( right, bottom )
  -- update our bounds to keep track of our grid size
  if not rect.containsPoint(self.gridBounds.x, self.gridBounds.y, self.gridBounds.w, self.gridBounds.h, px1, py1) then
    local x, y, w, h = rect.union(self.gridBounds.x, self.gridBounds.y, self.gridBounds.w, self.gridBounds.h, 0, 0, px1, py1)
    self.gridBounds.x = x
    self.gridBounds.y = y
    self.gridBounds.w = w
    self.gridBounds.h = h
  end

  if not rect.containsPoint(self.gridBounds.x, self.gridBounds.y, self.gridBounds.w, self.gridBounds.h, px2, py2) then
    local x, y, w, h = rect.union(self.gridBounds.x, self.gridBounds.y, self.gridBounds.w, self.gridBounds.h, 0, 0, px2, py2)
    self.gridBounds.x = x
    self.gridBounds.y = y
    self.gridBounds.w = w
    self.gridBounds.h = h
  end
  
  for x = px1, px2 do
    for y = py1, py2 do 
      -- we need to create the cell if there is none
      local c = self:cellAtPosition(x, y)
      lume.push(c, box)
    end
  end
end

function SpatialHash:remove(box)
  local bounds = box.registeredPhysicsBounds
  local px1, py1 = self:cellCoords(bounds.x, bounds.y)
  local px2, py2 = self:cellCoords(bounds.x + bounds.w, bounds.y + bounds.h)  -- ( right, bottom )
  for x = px1, px2 do
    for y = py1, py2 do
      -- this cell should always exist since this collider should be in all queryed cells
      local c = self:cellAtPosition(x, y)
      lume.remove(c, box)
    end
  end
end

function SpatialHash:removeWithBruteForce(box)
  for x, cr in ipairs(self.cellDict) do
    for y, c in ipairs(cr) do
      lume.remove(c, box)
    end
  end
end

function SpatialHash:clear()
  lume.clear(self.cellDict)
end

function SpatialHash:aabbBroadphase(box, boundsX, boundsY, boundsW, boundsH)
  local boxes = TablePool.obtain()
  local px1, py1 = self:cellCoords(boundsX, boundsY)
  local px2, py2 = self:cellCoords(boundsX + boundsW, boundsY + boundsH)  -- ( right, bottom )
  for x = px1, px2 do
    for y = py1, py2 do
      local cell = self:cellAtPosition(x, y)
      for i, otherBox in ipairs(cell) do
        if otherBox ~= box then
          if box:reportsCollisionsWith(otherBox)
            and rect.intersects(boundsX, boundsY, boundsW, boundsH, otherBox.x, otherBox.y, otherBox.w, otherBox.h) 
            and box.zRange.max > otherBox.zRange.min and box.zRange.min < otherBox.zRange.max
            and box:additionalPhysicsFilter(otherBox) then
            lume.push(boxes, otherBox)
          end
        end
      end
    end
  end
  return boxes
end

function SpatialHash:linecast(startX, startY, endX, endY, hits, layerMask, zmin, zmax)
  local directionX, directionY = vector.sub(endX, endY, startX, startY)
  self.raycastResultParser:start(startX, startY, endX, endY, hits, layerMask, zmin, zmax)

  -- get our start/end position in the same space as our grid
  local currentCellX, currentCellY = self:cellCoords(startX, startY)
  local lastCellX, lastCellY = self:cellCoords(endX, endY)

  -- what direction are we incrementing the cell checks?
  local stepX = sign(directionX)
  local stepY = sign(directionY)

  -- make sure that if we're on the same line or row we don't step in the unneeded direction
  if currentCellX == lastCellX then
    stepX = 0
  end
  if currentCellY == lastCellY then
    stepY = 0
  end

  -- Calculate cell boundaries. When the step is positive, the next cell is after this one meaning we add 1
  -- If negative, cell is before this one in which case we dont add to the boundary
  local xStep = 0
  local yStep = 0
  if stepX > 0 then
    xStep = stepX
  end
  if stepY > 0 then
    yStep = stepY
  end
  local nextBoundaryX = (currentCellX + xStep) * self.cellSize
  local nextBoundaryY = (currentCellY + yStep) * self.cellSize

  -- determine the value of t at which the ray crosses the first vertical voxel boundary. same for y/horizontal
  -- The minimum of these two values will indicate how much we can travel along the ray and still remain in the current voxel
  -- may be infinite for near vertical/horizontal rays
  local tMaxX = 0
  local tMaxY = 0
  if directionX == 0 then
    tMaxX = math.maxinteger
  else
    tMaxX = (nextBoundaryX - startX) / directionX
  end
  if directionY == 0 then
    tMaxY = math.maxinteger
  else
    tMaxY = (nextBoundaryY - startY) / directionY
  end

  -- how far do we have to walk before crossing a cell from a cell boundary, may be infinite for near vertical/horizontal rays
  local tDeltaX = 0
  local tDeltaY = 0
  if directionX == 0 then
    tDeltaX = math.maxinteger
  else
    tDeltaX = self.cellSize / (directionX * stepX)
  end
  if directionY == 0 then
    tDeltaY = math.maxinteger
  else
    tDeltaY = self.cellSize / (directionY * stepY)
  end
  
  -- start walking and returning the intersecting cells
  local cell = self:cellAtPosition(currentCellX, currentCellY)
  if cell ~= nil  then
    self.raycastResultParser:checkRayIntersection(currentCellX, currentCellY, cell)
  end
  while currentCellX ~= lastCellX or currentCellY ~= lastCellY do
    if tMaxX < tMaxY then
      -- HACK: ensures we never overshoot our values
      currentCellX = math.floor(approach(currentCellX, lastCellX, math.abs(stepX)))
      tMaxX = tMaxX + tDeltaX
    else
      currentCellY = math.floor(approach(currentCellY, lastCellY, math.abs(stepY)))
      tMaxY = tMaxY + tDeltaY
    end
    cell = self:cellAtPosition(currentCellX, currentCellY)
    if cell ~= nil then
      self.raycastResultParser:checkRayIntersection(currentCellX, currentCellY, cell)
    end
  end
  self.raycastResultParser:reset()
  return self.raycastResultParser.hitCounter
end


return SpatialHash
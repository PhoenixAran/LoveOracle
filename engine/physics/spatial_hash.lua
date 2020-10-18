local Class = require 'lib.class'
local lume = require 'lib.lume'
local rect = require 'engine.utils.rectangle'

local SpatialHash = Class {
  init = function(self, cellSize)
    if cellSize == nil then cellSize = 32 end
    
    self.cellSize = cellSize
    self.inverseCellSize = 1 / cellSize
    
    self.cellDict = { }
    self.tempHashSet = { }
    
    self.gridBounds = { x = 0, y = 0, w = 0, h = 0 }
    self.overlapTestBox = { x = 0, y = 0, w = 0, h = 0 }
  end
}

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
      local c = self:cellAtPosition(x, y, true)
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
  lume.clear(self.tempHashSet)
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
            lume.push(self.tempHashSet, otherBox)
          end
        end
      end
    end
  end
  return self.tempHashSet
end

return SpatialHash
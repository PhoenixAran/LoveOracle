local Class = require 'lib.class'
local lume = require 'lib.lume'
local rect = require 'lib.rectangle'

local SpatialHash = Class {
  init = function(self, cellSize)
    if cellSize == nil then cellSize = 32 end
    self.gridBounds = { x = 0, y = 0, w = 0, h = 0 }
    self.cellSize = nil
    self.inverseCellSize = nil
    self.overlapTestBox = { x = 0, y = 0, w = 0, h = 0 }
    self.cellDict = { }
    self.tempHashSet = { }
  end
}

function SpatialHash:cellCoords(x, y)
  return math.floor(x * self.cellSize), math.floor(y * self.inverseCellSize)
end

function SpatialHash:cellAtPosition(x, y)
  local cell = self.cellDict[tostring(x) .. tostring(y)]
  if cell == nil then
    cell = { }
    self.cellDict[tostring(x) .. tostring(y)] = cell
  end
  return cell
end

function SpatialHash:register(box)
  local bx, by, bw, bh = box:getBounds()
  box.registeredPhysicsBounds = { x = bx, y = by, w = bw, h = bh }
  local px1, py1 = self:cellCoords(bx, by)
  local px2, py2 = self:cellCoords(bx + bw, by + bh)  -- ( right, bottom )
  
  -- update our bounds to keep track of our grid size
  if not rect.containsPoint(self.gridBounds, px1, py2) then
    self.gridBounds = rect.union(self.gridBounds, { x = 0, y = 0, w = px1, h = py2 })
  end
  
  if not rect.containsPoint(self.gridBounds, px2, py2) then
    self.gridBounds = rect.union(self.gridBounds, { x = 0, y = 0, w = px2, h = py2})
  end
  
  for x = px1, px2 do
    for y = py1, py2 do 
      -- we need to create the cell if there is non
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
      local c = self:cellAtPosition(x, y, true)
      lume.remove(c, box)
    end
  end
end

function SpatialHash:removeWithBruteForce(box)
  for k, v in pairs(self.cellDict) do
    lume.remove(v, box)
  end
end

function SpatialHash:clear()
  lume.clear(self.cellDict)
end

function SpatialHash:aabbBroadphase(bound, box)
  lume.clear(self.tempHashSet)
  local px1, py1 = self:cellCoords(bounds.x, bounds.y)
  local px2, py2 = self:cellCoords(bounds.x + bounds.w, bounds.y + bounds.h)  -- ( right, bottom )
  for x = px1, px2 do
    for y = py1, py2 do
      local cell = self:cellAtPosition(x, y)
      for i, otherBox in ipairs(cell) do
        if box:reportsCollisionsWith(otherBox) and rect.intersects(box, otherBox) then
          lume.push(self.tempHashSet, otherBox)
        end
      end
    end
  end
end

return SpatialHash
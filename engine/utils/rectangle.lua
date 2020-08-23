-- methods for rectangle collisions
local lume = require 'lib.lume'
local vector = require 'lib.vector'

-- module function holder
local rectMethods = { }

function rectMethods.union(rect1, rect2)
  local result = { }
  
  local resultX = math.min(rect1.x, rect2.x)
  local resultY = math.min(rect1.y, rect2.y)
  local resultW = math.max(rect1.x + rect1.w, rect2.x + rect2.w)
  local resultH = math.max(rect1.y + rect1.h, rect2.y + rect2.h)
  
  result.x = resultX
  result.y = resultY
  result.w = resultW
  result.h = resultH
  
  return result
end

function rectMethods.intersects(rect1, rect2)
  --return x1 < x2 + w2 and x2 < x1 + w1 and
  --       y1 < y2 + h2 and y2 < y1 + h1
  return rect1.x < rect2.x + rect2.w and rect2.x < rect1.x + rect1.w and
         rect1.y < rect2.y + rect2.y and rect2.y < rect1.y + rect1.h
end

function rectMethods.containsPoint(rect, px, py)
  return rect.x <= px and px < rect.x + rect.w and
         rect.y <= py and py < rect.y + rect.h
end

function rectMethods.getClosestPointOnBoundsToOrigin(box)
  local maxX = box.x + box.w
  local maxY = box.y + box.h
  local minDist = math.abs(box.x)
  local boundsX, boundsY = minDist, 0  
  if math.abs(maxX) < minDist then
    minDist = math.abs(maxX)
    boundsX = maxX
    boundsY = 0
  end
  
  if math.abs(maxY) < minDist then
    minDist = math.abs(maxY)
    boundsX = 0
    boundsY = maxY
  end
  
  if math.abs(box.y) < minDist then
    minDist = math.abs(box.y)
    boundsX = 0
    boundsY = box.y
  end
  
  return boundsX, boundsY
end

-- returns if the box1 collides with box2, the minimum translation vector, and the normal vector 
-- between box1 and box2
function rectMethods.boxToBox(box1, box2)
  local minkowskiDifference = rectMethods.minkowskiDifference(box1, box2)
  if rectMethods.containsPoint(minkowskiDifference, 0, 0) then
    local mtvX, mtvY = rectMethods.getClosestPointOnBoundsToOrigin(minkowskiDifference)
    local normX, normY = vector.normalize(vector.mul(-1, mtvX, mtvY))
    return true, mtvX, mtvY, normX, normY
  end
  return false, 0, 0, 0, 0
end

-- temporary rectangle used in minkowskiDifference
local tempRect = { }
function rectMethods.minkowskiDifference(box1, box2)
  tempRect.x = box2.x - box1.x - box1.w
  tempRect.y = box2.y - box1.y - box1.h
  tempRect.w = box1.w + box2.w
  tempRect.h = box1.h + box2.h
  return tempRect
end

return rectMethods
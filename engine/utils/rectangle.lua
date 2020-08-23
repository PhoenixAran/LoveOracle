-- methods for rectangle collisions
local lume = require 'lib.lume'
local vector = require 'lib.vector'

-- module function holder
local rectMethods = { }

function rectMethods.union(x1, y1, w1, h1,  x2, y2, w2, h2)
  local resultX = math.min(x1, x2)
  local resultY = math.min(y1, y2)
  local resultW = math.max(x1 + w1, x2 + w2)
  local resultH = math.max(y1 + h1, y2 + h2)
  
  return resultX, resultY, resultW, resultH
end

function rectMethods.intersects(x1, y1, w1, h1,  x2, y2, w2, h2)
  return x1 < x2 + w2 and x2 < x1 + w1 and
         y1 < y2 + h2 and y2 < y1 + h1
end

function rectMethods.containsPoint(x, y, w, h, px, py)
  return x <= px and px < x + w and
         y <= py and py < y + h
end

function rectMethods.getClosestPointOnBoundsToOrigin(x, y, w, h)
  local maxX = x + w
  local maxY = y + h
  local minDist = math.abs(x)
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
  
  if math.abs(y) < minDist then
    minDist = math.abs(y)
    boundsX = 0
    boundsY = y
  end
  
  return boundsX, boundsY
end

-- returns if the box1 collides with box2, the minimum translation vector, and the normal vector 
-- between box1 and box2
function rectMethods.boxToBox(box1, box2)
  local mdX, mdY, mdW, mdH = rectMethods.minkowskiDifference(box1, box2)
  if rectMethods.containsPoint(mdX, mdY, mdW, mdH, 0, 0) then
    local mtvX, mtvY = rectMethods.getClosestPointOnBoundsToOrigin(mdX, mdY, mdW, mdH)
    local normX, normY = vector.normalize(vector.mul(-1, mtvX, mtvY))
    return true, mtvX, mtvY, normX, normY
  end
  return false, 0, 0, 0, 0
end

-- temporary rectangle used in minkowskiDifference
function rectMethods.minkowskiDifference(box1, box2)
  local mdx = box2.x - box1.x - box1.w
  local mdy = box2.y - box1.y - box1.h
  local mdw = box1.w + box2.w
  local mdh = box1.h + box2.h
  return mdx, mdy, mdw, mdh
end

return rectMethods
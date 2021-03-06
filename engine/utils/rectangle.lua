-- methods for rectangle collisions
local lume = require 'lib.lume'
local vector = require 'lib.vector'

-- floating-point margin of error
local DELTA = 1e-10

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
  return px - x > DELTA      and py - y > DELTA and
         x + w - px > DELTA  and y + h - py > DELTA
end

function rectMethods.getClosestPointOnBoundsToOrigin(x, y, w, h)
  local maxX = x + w
  local maxY = y + h
  local minDist = math.abs(x)
  local boundsX, boundsY = x, 0  
  
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
function rectMethods.boxToBox(x1, y1, w1, h1,  x2, y2, w2, h2)
  local mdX, mdY, mdW, mdH = rectMethods.minkowskiDifference(x2, y2, w2, h2, x1, y1, w1, h1)
  if rectMethods.containsPoint(mdX, mdY, mdW, mdH, 0, 0) then
    local mtvX, mtvY = rectMethods.getClosestPointOnBoundsToOrigin(mdX, mdY, mdW, mdH)
    if mtvX == 0 and mtvY == 0 then
      return false, 0, 0, 0, 0
    end
    local normX, normY = vector.normalize(vector.mul(-1, mtvX, mtvY))
    return true, mtvX, mtvY, normX, normY
  end
  return false, 0, 0, 0, 0
end

function rectMethods.minkowskiDifference(x1, y1, w1, h1,  x2, y2, w2, h2)
  return x2 - x1 - w1,
         y2 - y1 - h1,
         w1 + w2,
         h1 + h2
end

function rectMethods.resizeAroundCenter(x, y, w, h, newWidth, newHeight)
  local ox, oy = x + w / 2, y + h / 2
  w = newWidth
  h = newHeight
  x = ox - w / 2
  y = oy - h / 2
  return x, y, w, h
end

return rectMethods
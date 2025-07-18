-- methods for rectangle collisions
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Direction4 = require 'engine.enums.direction4'

-- floating-point margin of error
local DELTA = 1e-10

local abs, floor, ceil, min, max = math.abs, math.floor, math.ceil, math.min, math.max

-- module function holder
local rectMethods = { }

local function nearest(x, a, b)
  if abs(a - x) < abs(b - x) then
    return a
  end
  return b
end

function rectMethods.union(x1, y1, w1, h1,  x2, y2, w2, h2)
  local resultX = min(x1, x2)
  local resultY = min(y1, y2)
  local resultW = max(x1 + w1, x2 + w2)
  local resultH = max(y1 + h1, y2 + h2)

  return resultX, resultY, resultW, resultH
end

function rectMethods.resizeAroundCenter(x, y, w, h, newWidth, newHeight)
  local ox, oy = x + w / 2, y + h / 2
  w = newWidth
  h = newHeight
  x = ox - w / 2
  y = oy - h / 2
  return x, y, w, h
end

function rectMethods.getNearestCorner(x,y,w,h, px, py)
  return nearest(px, x, x+w), nearest(py, y, y+h)
end

---this is a generalized implementation of the liang-barsky algorithm, which also returns
-- the normals of the sides where the segment intersects. 
-- returns nil if the segment never touches the rect
-- notice that the normals are only guaranteed to be accurate when initially ti1, ti2 == -math.huge, math.huge
---@param x number
---@param y number
---@param w number
---@param h number
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param ti1 number
---@param ti2 number
---@return number|nil ti1
---@return number|nil ti2 number
---@return number|nil nx1
---@return number|nil ny1
---@return number|nil nx2
---@return number|nil ny2
function rectMethods.getSegmentIntersectionIndices(x, y, w, h,  x1, y1, x2, y2,  ti1, ti2)
  ti1, ti2 = ti1 or 0, ti2 or 1
  local dx, dy = x2-x1, y2-y1
  local nx, ny
  local nx1, ny1, nx2, ny2 = 0,0,0,0
  local p, q, r

  for side = 1,4 do
    if     side == 1 then nx,ny,p,q = -1,  0, -dx, x1 - x     -- left
    elseif side == 2 then nx,ny,p,q =  1,  0,  dx, x + w - x1 -- right
    elseif side == 3 then nx,ny,p,q =  0, -1, -dy, y1 - y     -- top
    else                  nx,ny,p,q =  0,  1,  dy, y + h - y1 -- bottom
    end

    if p == 0 then
      if q <= 0 then return nil end
    else
      r = q / p
      if p < 0 then
        if     r > ti2 then return nil
        elseif r > ti1 then ti1,nx1,ny1 = r,nx,ny
        end
      else -- p > 0
        if     r < ti1 then return nil
        elseif r < ti2 then ti2,nx2,ny2 = r,nx,ny
        end
      end
    end
  end
  return ti1,ti2, nx1,ny1, nx2,ny2
end

---calculates the minkowsky difference between 2 rects, which is another rect
---@param x1 number
---@param y1 number
---@param w1 number
---@param h1 number
---@param x2 number
---@param y2 number
---@param w2 number
---@param h2 number
---@return number
---@return number
---@return number
---@return number
function rectMethods.getDiff(x1,y1,w1,h1, x2,y2,w2,h2)
  return x2 - x1 - w1,
         y2 - y1 - h1,
         w1 + w2,
         h1 + h2
end

function rectMethods.isIntersecting(x1, y1, w1, h1,  x2, y2, w2, h2)
  return x1 < x2 + w2 and x2 < x1 + w1 and
         y1 < y2 + h2 and y2 < y1 + h1
end

function rectMethods.containsPoint(x, y, w, h, px, py)
  return px - x > DELTA      and py - y > DELTA and
         x + w - px > DELTA  and y + h - py > DELTA
end

function rectMethods.getSquaredDistance(x1,y1,w1,h1, x2,y2,w2,h2)
  local dx = x1 - x2 + (w1 - w2)/2
  local dy = y1 - y2 + (h1 - h2)/2
  return dx*dx + dy*dy
end

return rectMethods
local Class = require 'lib.class'
local rect = require 'engine.utils.rectangle'
-- based off https://github.com/kikito/bump.lua
local Physics = {

}


-- helper functions
local DELTA = 1e-10 -- floating-point margin of error
local abs, floor, ceil, min, max = math.abs, math.floor, math.ceil, math.min, math.max

local function sign(x)
  if x > 0 then return 1 end
  if x == 0 then return 0 end
  return -1
end

local function nearest(x, a, b)
  if abs(a - x) < abs(b - x) then
    return a
  end
  return b
end

local function assertType(desiredType, value, name)
  if type(value) ~= desiredType then
    error(name .. ' must be a ' .. desiredType .. ', but was ' .. tostring(value) .. '(a ' .. type(value) .. ')')
  end
end

local function assertIsPositiveNumber(value, name)
  if type(value) ~= 'number' or value <= 0 then
    error(name .. ' must be a positive integer, but was ' .. tostring(value) .. '(' .. type(value) .. ')')
  end
end

local function assertIsRect(x,y,w,h)
  assertType('number', x, 'x')
  assertType('number', y, 'y')
  assertIsPositiveNumber(w, 'w')
  assertIsPositiveNumber(h, 'h')
end

local defaultFilter = function()
  return 'slide'
end

--- poolable collision info class
---@class CollisionInfo
---@field item any the item being moved
---@field other any an item colliding with the item being moved
---@field type string? the result of filter(other) Its usually touch, cross, slide or bounce
---@field overlaps boolean True if the item was overlapping other when the collision started. False if it didnt but tunneled through other
---@field ti number between 0 and 1. H ow far along the movement to the goal did the collision occur?
---@field moveX number the difference between the original coordinates and the actual one 
---@field moveY number the difference between the original coordinates and the actual one
---@field normalX number the collision normal, usually -1,0, or 1 
---@field normalY number the collision normal, usually -1,0, or 1
---@field touchX number the coordinates where the item started touching other
---@field touchY number the coordinates where the item started touching other
---@field itemRect table? the rectangle item occupied when the touch happend
---@field otherRect table? the rectangle other occupied when the touch happend
local CollisionInfo = require('lib.class') {
  init = function(self)
    self.item = nil
    self.other = nil
    self.type = nil
    self.overlaps = false
    self.ti = 0
    self.moveX = 0
    self.moveY = 0
    self.normalX = 0
    self.normalY = 0
    self.touchX = 0
    self.touchY = 0
    self.itemRect = nil
    self.otherRect = nil
  end
}

function CollisionInfo:getType()
  return 'collision_info'
end

function CollisionInfo:reset()
  self.item = nil
  self.other = nil
  self.type = nil
  self.overlaps = false
  self.ti = 0
  self.moveX = 0
  self.moveY = 0
  self.normalX = 0
  self.normalY = 0
  self.touchX = 0
  self.touchY = 0
  self.itemRect.x = 0
  self.itemRect.y = 0
  self.itemRect.w = 0
  self.itemRect.h = 0
  self.otherRect.x = 0
  self.otherRect.y = 0
  self.otherRect.w = 0
  self.otherRect.h = 0
end

local Pool = require 'engine.utils.pool'
Pool.register('collision_info', CollisionInfo)

---@param x1 number
---@param y1 number
---@param w1 number
---@param h1 number
---@param x2 number
---@param y2 number
---@param w2 number
---@param h2 number
---@param goalX number
---@param goalY number
---@return CollisionInfo?
local function detectCollision(x1,y1,w1,h1, x2,y2,w2,h2, goalX, goalY)
  goalX = goalX or x1
  goalY = goalY or y1

  local dx, dy      = goalX - x1, goalY - y1
  local x,y,w,h     = rect.getDiff(x1,y1,w1,h1, x2,y2,w2,h2)

  local overlaps, ti, nx, ny

  if rect.containsPoint(x,y,w,h, 0,0) then -- item was intersecting other
    local px, py    = rect.getNearestCorner(x,y,w,h, 0, 0)
    local wi, hi    = min(w1, abs(px)), min(h1, abs(py)) -- area of intersection
    ti              = -wi * hi -- ti is the negative area of intersection
    overlaps = true
  else
    local ti1,ti2,nx1,ny1 = rect.getSegmentIntersectionIndices(x,y,w,h, 0,0,dx,dy, -math.huge, math.huge)

    -- item tunnels into other
    if ti1
    and ti1 < 1
    and (abs(ti1 - ti2) >= DELTA) -- special case for rect going through another rect's corner
    and (0 < ti1 + DELTA
      or 0 == ti1 and ti2 > 0)
    then
      ti, nx, ny = ti1, nx1, ny1
      overlaps   = false
    end
  end

  if not ti then return end

  local tx, ty

  if overlaps then
    if dx == 0 and dy == 0 then
      -- intersecting and not moving - use minimum displacement vector
      local px, py = rect.getNearestCorner(x,y,w,h, 0,0)
      if abs(px) < abs(py) then py = 0 else px = 0 end
      nx, ny = sign(px), sign(py)
      tx, ty = x1 + px, y1 + py
    else
      -- intersecting and moving - move in the opposite direction
      local ti1, _
      ti1,_,nx,ny = rect.getSegmentIntersectionIndices(x,y,w,h, 0,0,dx,dy, -math.huge, 1)
      if not ti1 then return end
      tx, ty = x1 + dx * ti1, y1 + dy * ti1
    end
  else -- tunnel
    tx, ty = x1 + dx * ti, y1 + dy * ti
  end
  local collisionInfo = Pool.obtain('colliison_info')
  collisionInfo.overlaps = overlaps
  collisionInfo.ti = ti
  collisionInfo.moveX = dx
  collisionInfo.moveY = dy
  collisionInfo.normalX = nx
  collisionInfo.normalY = ny
  collisionInfo.touchX = tx
  collisionInfo.touchY = ty
  collisionInfo.itemRect = {
    x = x1,
    y = y1,
    w = w1,
    h = h1
  }
  collisionInfo.itemRect = {
    x = x2,
    y = y2,
    w = w2,
    h = h2
  }
  return collisionInfo
end

-- grid functions
local function grid_toWorld(cellSize, cx, cy)
  return (cx - 1)*cellSize, (cy-1)*cellSize
end

local function grid_toCell(cellSize, x, y)
  return floor(x / cellSize) + 1, floor(y / cellSize) + 1
end

-- grid_traverse* functions are based on "A Fast Voxel Traversal Algorithm for Ray Tracing",
-- by John Amanides and Andrew Woo - http://www.cse.yorku.ca/~amana/research/grid.pdf
-- It has been modified to include both cells when the ray "touches a grid corner",
-- and with a different exit condition
local function grid_traverse_initStep(cellSize, ct, t1, t2)
  local v = t2 - t1
  if     v > 0 then
    return  1,  cellSize / v, ((ct + v) * cellSize - t1) / v
  elseif v < 0 then
    return -1, -cellSize / v, ((ct + v - 1) * cellSize - t1) / v
  else
    return 0, math.huge, math.huge
  end
end

local function grid_traverse(cellSize, x1,y1,x2,y2, f)
  local cx1,cy1        = grid_toCell(cellSize, x1,y1)
  local cx2,cy2        = grid_toCell(cellSize, x2,y2)
  local stepX, dx, tx  = grid_traverse_initStep(cellSize, cx1, x1, x2)
  local stepY, dy, ty  = grid_traverse_initStep(cellSize, cy1, y1, y2)
  local cx,cy          = cx1,cy1

  f(cx, cy)

  -- The default implementation had an infinite loop problem when
  -- approaching the last cell in some occassions. We finish iterating
  -- when we are *next* to the last cell
  while abs(cx - cx2) + abs(cy - cy2) > 1 do
    if tx < ty then
      tx, cx = tx + dx, cx + stepX
      f(cx, cy)
    else
      -- Addition: include both cells when going through corners
      if tx == ty then f(cx + stepX, cy) end
      ty, cy = ty + dy, cy + stepY
      f(cx, cy)
    end
  end

  -- If we have not arrived to the last cell, use it
  if cx ~= cx2 or cy ~= cy2 then f(cx2, cy2) end
end

local function grid_toCellRect(cellSize, x,y,w,h)
  local cx,cy = grid_toCell(cellSize, x, y)
  local cr,cb = ceil((x+w) / cellSize), ceil((y+h) / cellSize)
  return cx, cy, cr - cx + 1, cb - cy + 1
end

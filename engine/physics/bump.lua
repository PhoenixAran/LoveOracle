local Class = require 'lib.class'
local rectangle = require 'engine.utils.rectangle'
local TablePool = require 'engine.utils.table_pool'
local Pool = require 'engine.utils.pool'
local lume = require 'lib.lume'

-- modified version of https://github.com/kikito/bump.lua that uses our pool classes and rectangle methods for more efficient use of memory

-- the module
local bump = { }

------------------------------------------
-- Helper functions
------------------------------------------
local DELTA = 1e-10 -- floating-point margin of error
local abs, floor, ceil, min, max = math.abs, math.floor, math.ceil, math.min, math.max

local function sign(x)
  if x > 0 then return 1 end
  if x == 0 then return 0 end
  return -1
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

------------------------------------------
-- CollisionInfo and Collision Detection
------------------------------------------

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
---@field responseVars table<string, number> custom response variables used by response types
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
    self.itemRect = { }
    self.otherRect ={ }
    self.responseVars = {}
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
  lume.clear(self.responseVars)
end

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
  local x,y,w,h     = rectangle.getDiff(x1,y1,w1,h1, x2,y2,w2,h2)

  local overlaps, ti, nx, ny

  if rectangle.containsPoint(x,y,w,h, 0,0) then -- item was intersecting other
    local px, py    = rectangle.getNearestCorner(x,y,w,h, 0, 0)
    local wi, hi    = min(w1, abs(px)), min(h1, abs(py)) -- area of intersection
    ti              = -wi * hi -- ti is the negative area of intersection
    overlaps = true
  else
    local ti1,ti2,nx1,ny1 = rectangle.getSegmentIntersectionIndices(x,y,w,h, 0,0,dx,dy, -math.huge, math.huge)

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

  if not ti then return nil end

  local tx, ty

  if overlaps then
    if dx == 0 and dy == 0 then
      -- intersecting and not moving - use minimum displacement vector
      local px, py = rectangle.getNearestCorner(x,y,w,h, 0,0)
      if abs(px) < abs(py) then py = 0 else px = 0 end
      nx, ny = sign(px), sign(py)
      tx, ty = x1 + px, y1 + py
    else
      -- intersecting and moving - move in the opposite direction
      local ti1, _
      ti1,_,nx,ny = rectangle.getSegmentIntersectionIndices(x,y,w,h, 0,0,dx,dy, -math.huge, 1)
      if not ti1 then return nil end
      tx, ty = x1 + dx * ti1, y1 + dy * ti1
    end
  else -- tunnel
    tx, ty = x1 + dx * ti, y1 + dy * ti
  end
  local collisionInfo = Pool.obtain('collision_info')

  collisionInfo.overlaps = overlaps
  collisionInfo.ti = ti
  collisionInfo.moveX = dx
  collisionInfo.moveY = dy
  collisionInfo.normalX = nx
  collisionInfo.normalY = ny
  collisionInfo.touchX = tx
  collisionInfo.touchY = ty
  collisionInfo.itemRect.x = x1
  collisionInfo.itemRect.y = y1
  collisionInfo.itemRect.w = w1
  collisionInfo.itemRect.h = h1
  collisionInfo.otherRect.x = x2
  collisionInfo.otherRect.y = y2
  collisionInfo.otherRect.w = w2
  collisionInfo.otherRect.h = h2
  return collisionInfo
end

------------------------------------------
-- Grid functions
------------------------------------------
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
------------------------------------------
-- Responses
------------------------------------------

---@param world World
---@param col CollisionInfo
---@param x number
---@param y number
---@param w number
---@param h number
---@param goalX number
---@param goalY number
---@param filter function
---@param alreadyVisited table
---@return number
---@return number
---@return any[]
---@return integer length
local function touch(world, col,  x,y,w,h, goalX, goalY, filter, alreadyVisited)
  return col.touchX, col.touchY, TablePool.obtain(), 0
end

---@param world World
---@param col CollisionInfo
---@param x number
---@param y number
---@param w number
---@param h number
---@param goalX number
---@param goalY number
---@param filter function
---@param alreadyVisited table
---@return number
---@return number
---@return any[]
---@return integer length
local function cross(world, col, x,y,w,h, goalX, goalY, filter, alreadyVisited)
  local cols, len = world:project(col.item, x,y,w,h, goalX, goalY, filter, alreadyVisited)
  return goalX, goalY, cols, len
end

---@param world World
---@param col CollisionInfo
---@param x number
---@param y number
---@param w number
---@param h number
---@param goalX number
---@param goalY number
---@param filter function
---@param alreadyVisited table
---@return number
---@return number
---@return any[]
---@return integer length
local function slide(world, col, x,y,w,h, goalX, goalY, filter, alreadyVisited)
  goalX = goalX or x
  goalY = goalY or y
  local tchx, tchy, movex, movey  = col.touchX, col.touchY, col.moveX, col.moveY
  if movex ~= 0 or movey ~= 0 then
    if col.normalX ~= 0 then
      goalX = tchx
    else
      goalY = tchy
    end
  end

  col.responseVars.slideX = goalX
  col.responseVars.slideY = goalY
  x,y = tchx, tchy
  local cols, len  = world:project(col.item, x,y,w,h, goalX, goalY, filter, alreadyVisited)
  return goalX, goalY, cols, len
end

---@param world World
---@param col CollisionInfo
---@param x number
---@param y number
---@param w number
---@param h number
---@param goalX number
---@param goalY number
---@param filter function
---@param alreadyVisited boolean
---@return number
---@return number
---@return any[]
---@return integer length
local function bounce(world, col, x,y,w,h, goalX, goalY, filter, alreadyVisited)
  goalX = goalX or x
  goalY = goalY or y

  local tchx, tchy, movex, movey  = col.touchX, col.touchY, col.moveX, col.moveY

  local bx, by = tchx, tchy

  if movex ~= 0 or movey ~= 0 then
    local bnx, bny = goalX - tchx, goalY - tchy
    if col.normalX == 0 then bny = -bny else bnx = -bnx end
    bx, by = tchx + bnx, tchy + bny
  end

  col.responseVars.bounceX = bx
  col.responseVars.bounceY = by
  
  x,y          = tchx, tchy
  goalX, goalY = bx, by

  local cols, len    = world:project(col.item, x,y,w,h, goalX, goalY, filter, alreadyVisited)
  return goalX, goalY, cols, len
end

------------------------------------------
-- Memory Management
------------------------------------------

--- Free array of collision info objects
local function mem_freeCollisionInfoArray(cols, len)
  if len == nil then
    len = lume.count(cols)
  end
  if len > 0 then
    for _, v in ipairs(cols) do
      Pool.free(v)
    end
  end
  TablePool.free(cols)
end


------------------------------------------
-- World
------------------------------------------

---@class World
---@field cellSize integer
---@field rects any[]
---@field rows any[]
---@field nonEmptyCells any[]
---@field responses table<string, function>
local World = Class {
  init = function(self)
    self.cellSize = 0
    self.rects = { }
    self.rows = { }
    self.nonEmptyCells = { }
    self.responses = { }
  end
}

function World:getType()
  return 'world'
end

-- Private functions and methods

local function sortByWeight(a, b)
  return a.weight < b.weight
end

local function sortByTiAndDistance(a,b)
  if a.ti == b.ti then
    local ir, ar, br = a.itemRect, a.otherRect, b.otherRect
    local ad = rectangle.getSquareDistance(ir.x,ir.y,ir.w,ir.h, ar.x,ar.y,ar.w,ar.h)
    local bd = rectangle.getSquareDistance(ir.x,ir.y,ir.w,ir.h, br.x,br.y,br.w,br.h)
    return ad < bd
  end
  return a.ti < b.ti
end

local function addItemToCell(self, item, cx, cy)
  self.rows[cy] = self.rows[cy] or setmetatable({}, {__mode = 'v'})
  local row = self.rows[cy]
  row[cx] = row[cx] or {itemCount = 0, x = cx, y = cy, items = setmetatable({}, {__mode = 'k'})}
  local cell = row[cx]
  self.nonEmptyCells[cell] = true
  if not cell.items[item] then
    cell.items[item] = true
    cell.itemCount = cell.itemCount + 1
  end
end

local function removeItemFromCell(self, item, cx, cy)
  local row = self.rows[cy]
  if not row or not row[cx] or not row[cx].items[item] then return false end

  local cell = row[cx]
  cell.items[item] = nil
  cell.itemCount = cell.itemCount - 1
  if cell.itemCount == 0 then
    self.nonEmptyCells[cell] = nil
  end
  return true
end

local function getDictItemsInCellRect(self, cl,ct,cw,ch)
  local items_dict = TablePool.obtain()
  for cy=ct,ct+ch-1 do
    local row = self.rows[cy]
    if row then
      for cx=cl,cl+cw-1 do
        local cell = row[cx]
        if cell and cell.itemCount > 0 then -- no cell.itemCount > 1 because tunneling
          for item,_ in pairs(cell.items) do
            items_dict[item] = true
          end
        end
      end
    end
  end

  return items_dict
end

--- remember to call TablePool.free on the the cells table when you are done
---@param self any
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@return table cells
---@return integer cellslen
local function getCellsTouchedBySegment(self, x1,y1,x2,y2)

  local cells, cellsLen, visited = TablePool.obtain(), 0, TablePool.obtain()

  grid_traverse(self.cellSize, x1,y1,x2,y2, function(cx, cy)
    local row  = self.rows[cy]
    if not row then return end
    local cell = row[cx]
    if not cell or visited[cell] then return end

    visited[cell] = true
    cellsLen = cellsLen + 1
    cells[cellsLen] = cell
  end)
  TablePool.free(visited)
  return cells, cellsLen
end

--ItemInfo class used in the getInfoItemsTouchedBySegment
---@class ItemInfo
---@field item any? item being intersected by the segment
---@field x1 number coordinates of the first intersection between item and the segment
---@field y1 number coordinates of the first intersection between item and the segment
---@field x2 number coordinates of the second intersection between item and the segmentgetInfoAboutItemsTouchedBySegment
---@field y2 number coordinates of the second intersection between item and the segment
---@field ti1 number between 0 and 1 which say how farr from the starting point did the impact happend
---@field ti2 number between 0 and 1 which say how farr from the starting point did the impact happend
---@field weight number
---@return ItemInfo[], number
local ItemInfo = Class {
  init = function(self)
    self.item = nil
    self.x1 = 0
    self.y1 = 0
    self.x2 = 0
    self.y2 = 0
    self.ti1 = 0
    self.ti2 = 0
  end
}

function ItemInfo:getType()
  return 'item_info'
end

function ItemInfo:reset()
  self.item = nil
  self.x1 = 0
  self.y1 = 0
  self.x2 = 0
  self.y2 = 0
  self.ti1 = 0
  self.ti2 = 0
end

Pool.register('item_info', ItemInfo)

local function getInfoAboutItemsTouchedBySegment(self, x1,y1, x2,y2, filter)
  local cells, len = getCellsTouchedBySegment(self, x1,y1,x2,y2)
  local cell, rect, l,t,w,h, ti1,ti2, tii0,tii1
  local visited, itemInfo, itemInfoLen = TablePool.obtain(),TablePool.obtain(),0
  for i=1,len do
    cell = cells[i]
    for item in pairs(cell.items) do
      if not visited[item] then
        visited[item]  = true
        if (not filter or filter(item)) then
          rect           = self.rects[item]
          l,t,w,h        = rect.x,rect.y,rect.w,rect.h

          ti1,ti2 = rectangle.getSegmentIntersectionIndices(l,t,w,h, x1,y1, x2,y2, 0, 1)
          if ti1 and ((0 < ti1 and ti1 < 1) or (0 < ti2 and ti2 < 1)) then
            -- the sorting is according to the t of an infinite line, not the segment
            tii0,tii1    = rectangle.getSegmentIntersectionIndices(l,t,w,h, x1,y1, x2,y2, -math.huge, math.huge)
            itemInfoLen  = itemInfoLen + 1
            local itemInfoObj = Pool.obtain('item_info')
            itemInfoObj.item = item
            itemInfoObj.ti1 = ti1
            itemInfoObj.ti2 = ti2
            itemInfoObj.weight = min(tii0, tii1)
            itemInfo[itemInfoLen] = itemInfoObj
          end
        end
      end
    end
  end
  table.sort(itemInfo, sortByWeight)
  TablePool.free(visited)
  return itemInfo, itemInfoLen
end

local function getResponseByName(self, name)
  local response = self.responses[name]
  if not response then
    error(('Unknown collision type: %s (%s)'):format(name, type(name)))
  end
  return response
end

-- Misc Public Methods

function World:addResponse(name, response)
  self.responses[name] = response
end

---@param item any
---@param x number
---@param y number
---@param w number
---@param h number
---@param goalX number
---@param goalY number
---@param filter function
---@return CollisionInfo[any]
---@return integer
function World:project(item, x,y,w,h, goalX, goalY, filter, alreadyVisited)
  assertIsRect(x,y,w,h)
  goalX = goalX or x
  goalY = goalY or y
  filter  = filter  or defaultFilter

  local collisions, len = TablePool.obtain(), 0

  local visited = TablePool.obtain()
  if item ~= nil then visited[item] = true end

  -- This could probably be done with less cells using a polygon raster over the cells instead of a
  -- bounding rect of the whole movement. Conditional to building a queryPolygon method
  local tl, tt = min(goalX, x),       min(goalY, y)
  local tr, tb = max(goalX + w, x+w), max(goalY + h, y+h)
  local tw, th = tr-tl, tb-tt

  local cl,ct,cw,ch = grid_toCellRect(self.cellSize, tl,tt,tw,th)

  local dictItemsInCellRect = getDictItemsInCellRect(self, cl,ct,cw,ch)
  for other,_ in pairs(dictItemsInCellRect) do
    if not visited[other] and (alreadyVisited == nil or not alreadyVisited[other]) then
      visited[other] = true
      local responseName = filter(item, other)
      if responseName then
        local ox,oy,ow,oh   = self:getRect(other)
        local col           = detectCollision(x,y,w,h, ox,oy,ow,oh, goalX, goalY)

        if col then
          col.other    = other
          col.item     = item
          col.type     = responseName

          len = len + 1
          collisions[len] = col
        end
      end
    end
  end
  TablePool.free(visited)
  TablePool.free(dictItemsInCellRect)

  table.sort(collisions, sortByTiAndDistance)

  return collisions, len
end

function World:countCells()
  local count = 0
  for _,row in pairs(self.rows) do
    for _,_ in pairs(row) do
      count = count + 1
    end
  end
  return count
end

function World:hasItem(item)
  return not not self.rects[item]
end

function World:getItems()
  local items, len = TablePool.obtain(), 0
  for item,_ in pairs(self.rects) do
    len = len + 1
    items[len] = item
  end
  return items, len
end

function World:countItems()
  local len = 0
  for _ in pairs(self.rects) do len = len + 1 end
  return len
end

function World:getRect(item)
  local rect = self.rects[item]
  if not rect then
    error('Item ' .. tostring(item) .. ' must be added to the world before getting its rect. Use world:add(item, x,y,w,h) to add it first.')
  end
  return rect.x, rect.y, rect.w, rect.h
end

function World:toWorld(cx, cy)
  return grid_toWorld(self.cellSize, cx, cy)
end

function World:toCell(x,y)
  return grid_toCell(self.cellSize, x, y)
end

-- Query methods

--- Returns the items that touch a given rectangle.
--- Remember to call TablePool.free on the returned array
---@param x number
---@param y number
---@param w number
---@param h number
---@param filter function
---@return table
---@return integer
function World:queryRect(x,y,w,h, filter)

  assertIsRect(x,y,w,h)

  local cl,ct,cw,ch = grid_toCellRect(self.cellSize, x,y,w,h)
  local dictItemsInCellRect = getDictItemsInCellRect(self, cl,ct,cw,ch)

  local items, len = TablePool.obtain(), 0

  local rect
  for item,_ in pairs(dictItemsInCellRect) do
    rect = self.rects[item]
    if (not filter or filter(item))
    and rectangle.isIntersecting(x,y,w,h, rect.x, rect.y, rect.w, rect.h)
    then
      len = len + 1
      items[len] = item
    end
  end

  return items, len
end

--- returns the items that touch a given point
--- Remember to call TablePool.free on the returned array
---@param x any
---@param y any
---@param filter function
---@return table
---@return integer
function World:queryPoint(x,y, filter)
  local cx,cy = self:toCell(x,y)
  local dictItemsInCellRect = getDictItemsInCellRect(self, cx,cy,1,1)

  local items, len = TablePool.obtain(), 0

  local rect
  for item,_ in pairs(dictItemsInCellRect) do
    rect = self.rects[item]
    if (not filter or filter(item))
    and rectangle.containsPoint(rect.x, rect.y, rect.w, rect.h, x, y)
    then
      len = len + 1
      items[len] = item
    end
  end
  TablePool.free(dictItemsInCellRect)

  return items, len
end

---Returns the items that touch a segment.
---It's useful for things like line-of-sight or modelling bullets or lasers.
---Remember to call TablePool.free on the returned array
---@param x1 number
---@param y1 number
---@param x2 number
---@param y2 number
---@param filter function
---@return table
---@return integer
function World:querySegment(x1, y1, x2, y2, filter)
  local itemInfo, len = getInfoAboutItemsTouchedBySegment(self, x1, y1, x2, y2, filter)
  local items = TablePool.obtain()
  for i=1, len do
    items[i] = itemInfo[i].item
  end
  return items, len
end


---An extended version of world:querySegment which returns the collision points of the segment with the items, in addition to the items.
-- Disposal of objects is tricky for this method. You have to manually empty the given returned ItemInfo array with Pool.free(),
-- then you have to call TablePool.free() on the array itself. 
---@param x1 any
---@param y1 any
---@param x2 any
---@param y2 any
---@param filter any
---@return any[]
---@return integer
function World:querySegmentWithCoords(x1, y1, x2, y2, filter)
  local itemInfo, len = getInfoAboutItemsTouchedBySegment(self, x1, y1, x2, y2, filter)
  local dx, dy        = x2-x1, y2-y1
  local info, ti1, ti2
  for i=1, len do
    info  = itemInfo[i]
    ti1   = info.ti1
    ti2   = info.ti2

    info.weight  = nil
    info.x1      = x1 + dx * ti1
    info.y1      = y1 + dy * ti1
    info.x2      = x1 + dx * ti2
    info.y2      = y1 + dy * ti2
  end
  return itemInfo, len
end


-- main methods

function World:add(item, x,y,w,h)
  local rect = self.rects[item]
  if rect then
    error('Item ' .. tostring(item) .. ' added to the world twice.')
  end
  assertIsRect(x,y,w,h)

  self.rects[item] = {x=x,y=y,w=w,h=h}

  local cl,ct,cw,ch = grid_toCellRect(self.cellSize, x,y,w,h)
  for cy = ct, ct+ch-1 do
    for cx = cl, cl+cw-1 do
      addItemToCell(self, item, cx, cy)
    end
  end

  return item
end


function World:remove(item)
  local x,y,w,h = self:getRect(item)

  self.rects[item] = nil
  local cl,ct,cw,ch = grid_toCellRect(self.cellSize, x,y,w,h)
  for cy = ct, ct+ch-1 do
    for cx = cl, cl+cw-1 do
      removeItemFromCell(self, item, cx, cy)
    end
  end
end

function World:update(item, x2,y2,w2,h2)
  local x1,y1,w1,h1 = self:getRect(item)
  w2,h2 = w2 or w1, h2 or h1
  assertIsRect(x2,y2,w2,h2)

  if x1 ~= x2 or y1 ~= y2 or w1 ~= w2 or h1 ~= h2 then

    local cellSize = self.cellSize
    local cl1,ct1,cw1,ch1 = grid_toCellRect(cellSize, x1,y1,w1,h1)
    local cl2,ct2,cw2,ch2 = grid_toCellRect(cellSize, x2,y2,w2,h2)

    if cl1 ~= cl2 or ct1 ~= ct2 or cw1 ~= cw2 or ch1 ~= ch2 then

      local cr1, cb1 = cl1+cw1-1, ct1+ch1-1
      local cr2, cb2 = cl2+cw2-1, ct2+ch2-1
      local cyOut

      for cy = ct1, cb1 do
        cyOut = cy < ct2 or cy > cb2
        for cx = cl1, cr1 do
          if cyOut or cx < cl2 or cx > cr2 then
            removeItemFromCell(self, item, cx, cy)
          end
        end
      end

      for cy = ct2, cb2 do
        cyOut = cy < ct1 or cy > cb1
        for cx = cl2, cr2 do
          if cyOut or cx < cl1 or cx > cr1 then
            addItemToCell(self, item, cx, cy)
          end
        end
      end

    end

    local rect = self.rects[item]
    rect.x, rect.y, rect.w, rect.h = x2,y2,w2,h2

  end
end

function World:move(item, goalX, goalY, filter)
  local actualX, actualY, cols, len = self:check(item, goalX, goalY, filter)

  self:update(item, actualX, actualY)

  return actualX, actualY, cols, len
end

function World:check(item, goalX, goalY, filter)
  filter = filter or defaultFilter
  local visited = TablePool.obtain()
  visited[item] = true

  local cols, len = TablePool.obtain(), 0

  local x,y,w,h = self:getRect(item)
  local projected_cols, projected_len = self:project(item, x,y,w,h, goalX,goalY, filter)
  while projected_len > 0 do
    local col = projected_cols[1]
    len       = len + 1
    cols[len] = col

    visited[col.other] = true

    local response = getResponseByName(self, col.type)
    --mem_freeCollisionInfoArray(projected_cols, projected_len)
    goalX, goalY, projected_cols, projected_len = response(
      self,
      col,
      x, y, w, h,
      goalX, goalY,
      filter,
      visited
    )
  end
 -- mem_freeCollisionInfoArray(projected_cols, projected_len)
  --TablePool.free(visited)

  return goalX, goalY, cols, len
end


-- Public library functions
---create a new world
---@param cellSize any
---@return World
bump.newWorld = function(cellSize)
  cellSize = cellSize or 64
  assertIsPositiveNumber(cellSize, 'cellSize')
  local world = World()
  world.cellSize = cellSize
  world:addResponse('touch', touch)
  world:addResponse('cross', cross)
  world:addResponse('slide', slide)
  world:addResponse('bounce', bounce)
  return world
end

bump.responses = {
  touch  = touch,
  cross  = cross,
  slide  = slide,
  bounce = bounce
}

bump.memory = {
  freeCollisionInfoArray = mem_freeCollisionInfoArray
}



bump.detectCollision = detectCollision

return bump
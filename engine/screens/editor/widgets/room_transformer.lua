local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local Slab = require 'lib.slab'
local SignalObject = require 'engine.signal_object'
local MapData = require 'engine.tiles.map_data'

local GRID_SIZE = MapData.GRID_SIZE
local RESIZER_MARGIN = 16

-- Friend Type
local RoomResizeSquare = Class { __includes = SignalObject,
  init = function(self, roomData, direction, camera)
    SignalObject.init(self)

    self:signal('roomResize')

    self.roomData = roomData
    self.direction = direction
    self.camera = camera
    self.state = 'none'
    self.x = 0
    self.y = 0
    self.cachedX = 0
    self.cachedY = 0 
    self.minX = 0
    self.minY = 0
    self.maxX = 0
    self.maxY = 0
    self.size = 24
    self.clickMousePosX = 0
    self.clickMousePosY = 0

    self.mouseState = { 
      isDown = false,
      canUpdate = true
    }
    -- we want a draw position for the resize square
    -- so we need to subtract 1 from the tilemap indices 
    local rx1, ry1 = roomData:getTopLeftPosition()
    rx1 = rx1 - 1
    ry1 = ry1 - 1
    local rx2, ry2 = roomData:getBottomRightPosition()
    --rx2 = rx2 - 1
    --ry2 = ry2 - 1
    
    rx1, ry1 = vector.mul(GRID_SIZE, rx1, ry1)
    rx2, ry2 = vector.mul(GRID_SIZE, rx2, ry2)
    local rw = roomData:getSizeX() * GRID_SIZE
    local rh = roomData:getSizeY() * GRID_SIZE

    
    if self.direction == 'up' then
      self.x = (rw / 2) + rx1
      self.y = ry1 - RESIZER_MARGIN
      self.maxY = ry2 - (GRID_SIZE * 3) + RESIZER_MARGIN
    elseif self.direction == 'down' then
      self.x = (rw / 2) + rx1
      self.y = ry2  + RESIZER_MARGIN
      self.minY = ry1 + (GRID_SIZE * 3) - RESIZER_MARGIN
    elseif self.direction == 'left' then
      self.x = rx1 - RESIZER_MARGIN
      self.y = (rh / 2) + ry1
      self.maxX = rx2 - (GRID_SIZE * 3) + RESIZER_MARGIN
    elseif self.direction == 'right' then
      self.x = rx2 + RESIZER_MARGIN
      self.y = (rh / 2) + ry1
      self.minX = rx1 + (GRID_SIZE * 3) - RESIZER_MARGIN
    end

  end
}

function RoomResizeSquare:resizeRoom()
  local x1, y1 = self.roomData:getTopLeftPosition()
  local x2, y2 = self.roomData:getBottomRightPosition()
  if self.direction == 'up' then
    -- change y1
    y1 = math.floor((self.y + RESIZER_MARGIN) / GRID_SIZE) + 1
  elseif self.direction == 'down' then
    -- change y2
    y2 = math.ceil((self.y - RESIZER_MARGIN) / GRID_SIZE)
  elseif self.direction == 'left' then
    -- change x1
    x1 = math.floor((self.x + RESIZER_MARGIN) / GRID_SIZE) + 1
  elseif self.direction == 'right' then
    -- change x2
    x2 = math.ceil((self.x - RESIZER_MARGIN) / GRID_SIZE)
  end
  self:emit('roomResize', self.roomData, x1, y1, x2, y2)
end

function RoomResizeSquare:update(dt)
  if Slab.IsMouseClicked(i) then
    self.mouseState.canUpdate = Slab.IsVoidHovered()
  end
  self.mouseState.isDown = self.mouseState.canUpdate and Slab.IsMouseDown(i) and Slab.IsVoidHovered()
  if self.state == 'drag' then
    if not self.mouseState.isDown then
      self:resizeRoom()
      self.state = 'none'
      return
    end
    local mx, my = self.camera:getMousePosition()

    if self.direction == 'up' then
      self.y = math.min(self.maxY, self.cachedY - self.clickMousePosY + my)
    elseif self.direction == 'down' then
      self.y = math.max(self.minY, self.cachedY - self.clickMousePosY + my)
    elseif self.direction == 'left' then
      self.x = math.min(self.maxX, self.cachedX - self.clickMousePosX + mx)
    elseif self.direction == 'right' then
      self.x = math.max(self.minX, self.cachedX - self.clickMousePosX + mx)
    end
  else
    local mx, my = self.camera:getMousePosition()
    if self.mouseState.isDown and Slab.IsVoidHovered() and
    rect.containsPoint(self.x - self.size / 2, self.y - self.size / 2, self.size, self.size, mx, my) then
      self.clickMousePosX = mx
      self.clickMousePosY = my
      self.cachedX = self.x
      self.cachedY = self.y
      self.state = 'drag'
    end
  end
end

function RoomResizeSquare:draw()
  if self.state == 'none' then
    love.graphics.setColor(153 / 255, 50 / 255, 204 / 255)
  else
    love.graphics.setColor(100 / 255, 149 / 255, 237 / 255)
  end
  love.graphics.rectangle('fill', self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
  love.graphics.setColor(1, 1, 1)
end

-- Friend Type
local RoomMover = Class { __includes = SignalObject,
  init = function(self, roomData, camera)
    SignalObject.init(self)

    self:signal('roomMove')

    self.roomData = roomData
    self.camera = camera
    self.onMove = onMove
    self.state = 'none'
    self.x = 0
    self.y = 0
    self.size = 24
    self.clickMousePosX = 0
    self.clickMousePosY = 0
    self.lastMousePosX = 0
    self.lastMousePosY = 0

    self.mouseState = {
      canUpdate = true,
      isDown = false
    }

    local rx, ry = roomData:getTopLeftPosition()
    rx = (rx - 1) * GRID_SIZE
    ry = (ry - 1) * GRID_SIZE
    local rw = roomData:getSizeX() * GRID_SIZE
    local rh = roomData:getSizeY() * GRID_SIZE

    self.x = rx + (rw / 2)
    self.y = ry + (rh / 2)
  end
}

function RoomMover:moveRoom()
  local rw = self.roomData:getSizeX() * GRID_SIZE
  local rh = self.roomData:getSizeY() * GRID_SIZE

  -- get top left coordinate from room mover's current position
  local x1 = math.floor((self.x - (rw / 2)) / GRID_SIZE) + 1
  local y1 = math.floor((self.y - (rh / 2)) / GRID_SIZE) + 1

  -- get bottom right coordinate from room mover's current position
  local x2 = math.floor((self.x + (rw / 2)) / GRID_SIZE)
  local y2 = math.floor((self.y + (rh / 2)) / GRID_SIZE)
  self:emit('roomMove', self.roomData, x1, y1, x2, y2)
end

function RoomMover:update(dt)
  if Slab.IsMouseClicked(i) then
    self.mouseState.canUpdate = Slab.IsVoidHovered()
  end
  self.mouseState.isDown = self.mouseState.canUpdate and Slab.IsMouseDown(i) and Slab.IsVoidHovered()

  if self.state == 'drag' then
    if not self.mouseState.isDown then
      self:moveRoom()
      self.state = 'none'
    else
      local mx, my = self.camera:getMousePosition()
      local dx = self.cachedX -  self.clickMousePosX + mx
      local dy = self.cachedY -  self.clickMousePosY + my

      self.x = dx
      self.y = dy
    end
  else
    local mx, my = self.camera:getMousePosition()
    if self.mouseState.isDown and 
    rect.containsPoint(self.x - self.size / 2, self.y - self.size / 2, self.size, self.size, mx, my) then
      self.clickMousePosX = mx
      self.clickMousePosY = my
      self.cachedX = self.x
      self.cachedY = self.y
      self.state = 'drag'
    end
  end
end

function RoomMover:draw()
  if self.state == 'none' then
    love.graphics.setColor(153 / 255, 50 / 255, 204 / 255)
  else
    love.graphics.setColor(100 / 255, 149 / 255, 237 / 255)
  end
  love.graphics.rectangle('fill', self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
  love.graphics.setColor(1, 1, 1)
end

-- Holds RoomResizeSquare instances for each side of the room
-- Also handles the room mover object
local RoomTransformer = Class { __includes = SignalObject,
  init = function(self, camera, roomData)
    SignalObject.init(self)

    self:signal('roomResize')
    self:signal('roomMove')
    self.roomData = roomData
    self.camera = camera
    self.initialized = false
    if self.roomData then
      self:initializeWidgets()
    end
  end
}

function RoomTransformer:initializeWidgets()
  self.initialized = true
  self.cachedRoomCoords = {
    topLeftPosX = self.roomData.topLeftPosX,
    topLeftPosY = self.roomData.topLeftPosY,
    sizeX = self.roomData.sizeX,
    sizeY = self.roomData.sizeY
  }

  self.roomMover = RoomMover(self.roomData, self.camera)
  self.upR = RoomResizeSquare(self.roomData, 'up', self.camera)
  self.downR = RoomResizeSquare(self.roomData, 'down', self.camera)
  self.leftR = RoomResizeSquare(self.roomData, 'left', self.camera)
  self.rightR = RoomResizeSquare(self.roomData, 'right', self.camera)
  self.resizers = { self.upR, self.downR, self.leftR, self.rightR }

  for _, r in ipairs(self.resizers) do
    r:connect('roomResize', self, 'onRoomResize')
  end
  self.roomMover:connect('roomMove', self, 'onRoomMove')
end

-- Signal Callbacks
function RoomTransformer:onRoomResize(roomData, x1, y1, x2, y2)
  self:emit('roomResize', roomData, x1, y1, x2, y2)
end

function RoomTransformer:onRoomMove(roomData, x1, y1, x2, y2)
  self:emit('roomMove', roomData, x1, y1, x2, y2)
end

-- if room is being resized this frame
-- Called when we want to find out if we want to handle the delete key
-- or pick another room
function RoomTransformer:isActive()
  if not self.initialized then
    return false
  end
  for _, r in ipairs(self.resizers) do
    if r.state == 'drag' then
      return true
    end
  end
  if self.roomMover.state == 'drag' then
    return true
  end
  return false
end

function RoomTransformer:setRoomData(roomData)
  self.roomData = roomData
  self:initializeWidgets()
end

function RoomTransformer:update(dt)
  -- check if the room data size changed
  -- If it did, reinit the room resizers and room mover
  local roomChanged = not (self.cachedRoomCoords.topLeftPosX == self.roomData.topLeftPosX and
  self.cachedRoomCoords.topLeftPosY == self.roomData.topLeftPosY and
  self.cachedRoomCoords.sizeX == self.roomData.sizeX and
  self.cachedRoomCoords.sizeY == self.roomData.sizeY)
  if roomChanged then
    self.roomMover:release()
    lume.each(self.resizers, 'release')
    self:initializeWidgets()
  end
  local updatedResizer = false
  local updatedMover = false
  for _, r in ipairs(self.resizers) do
    if r.state == 'drag' then
      r:update(dt)
      updatedResizer = true
    end
  end
  if not updatedResizer then
    if self.roomMover.state == 'drag' then
      self.roomMover:update(dt)
      updatedMover = true
    end
  end
  if not updatedResizer and not updatedMover then
    lume.each(self.resizers, 'update', dt)
    self.roomMover:update(dt)
  end
end

function RoomTransformer:draw()
  if self.roomMover.state == 'drag' then
    self.roomMover:draw()
  elseif self.leftR.state == 'drag' or self.rightR.state == 'drag' or self.upR.state == 'drag'
  or self.downR.state == 'drag' then
    self.leftR:draw()
    self.rightR:draw()
    self.upR:draw()
    self.downR:draw() 
  else
    self.roomMover:draw()
    self.leftR:draw()
    self.rightR:draw()
    self.upR:draw()
    self.downR:draw() 
  end

  love.graphics.setColor(1, 1, 204 / 255, 0.20)
  
  local x, y = self.roomData:getTopLeftPosition()
  x = (x - 1) * GRID_SIZE
  y = (y - 1) * GRID_SIZE
  local w = self.roomData:getSizeX() * GRID_SIZE
  local h = self.roomData:getSizeY() * GRID_SIZE
  if self.upR.state == 'drag' then
    y = self.upR.y + RESIZER_MARGIN
    h = self.downR.y - y - RESIZER_MARGIN
  elseif self.downR.state == 'drag' then
    h = self.downR.y - y - RESIZER_MARGIN
  elseif self.leftR.state == 'drag' then
    x = self.leftR.x + RESIZER_MARGIN
    w = self.rightR.x - x - RESIZER_MARGIN
  elseif self.rightR.state == 'drag' then
    w = self.rightR.x - x - RESIZER_MARGIN
  elseif self.roomMover.state == 'drag' then
    x = math.floor((self.roomMover.x - w / 2) / GRID_SIZE) * GRID_SIZE
    y = math.floor((self.roomMover.y - h / 2) / GRID_SIZE) * GRID_SIZE
  end

  love.graphics.setColor(1, 1, 204 / 255, 0.20)
  love.graphics.rectangle('fill', x, y, w, h)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle('line', x, y, w, h)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 1, 1)
end

return RoomTransformer
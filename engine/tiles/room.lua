local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'
local RoomEdge = require 'engine.entities.room_edge'
local Direction4 = require 'engine.enums.direction4'
local Tile = require 'engine.tiles.tile'

local GRID_SIZE = 16

local Room = Class { __includes = SignalObject,
  init = function(self, map, roomData)
    SignalObject.init(self)
    self:signal('roomTransitionRequest')
    self:signal('mapTransitionRequest')

    self.map = map
    self.topLeftPosX = roomData.topLeftPosX
    self.topLeftPosY = roomData.topLeftPosY
    self.width = roomData.width
    self.height = roomData.height
    -- entities that were spawned
    self.entities = { }
    -- ids of entities that were killed
    self.destroyedEntities = { }
    -- ids of tile entities that were destroyed
    self.destroyedTileEntities = { }
  end
}

function Room:getType()
  return 'room'
end

function Room:getTopLeftPosition()
  return self.topLeftPosX, self.topLeftPosY
end

function Room:getTopLeftPositionX()
  return self.topLeftPosX
end

function Room:getTopLeftPositionY()
  return self.topLeftPosY
end

function Room:getBottomRightPosition()
  return self.topLeftPosX + self.width - 1,  self.topLeftPosY + self.height - 1
end

function Room:getBottomRightPositionX()
  return self.topLeftPosX + self.width - 1
end

function Room:getBottomRightPositionY()
  return self.topLeftPosY + self.height - 1
end

function Room:getWidth()
  return self.width
end

function Room:getHeight()
  return self.height
end

function Room:load(entities)
  -- add tiles
  --print(require('lib.inspect').inspect(self))
  for layerIndex, tileLayer in ipairs(self.map:getTileLayers()) do
    for x = self:getTopLeftPositionX(), self:getBottomRightPositionX() do
      for y = self:getTopLeftPositionY(), self:getBottomRightPositionY() do
        local tileData = self.map:getTileData(x, y, layerIndex)
        if tileData then
          entities:addTileEntity(Tile(tileData, x, y, layerIndex))
        end
      end
    end
  end
  -- add room edges
  -- make left room edge
  local roomRect = {
    useBumpCoords = true,
    x = (self.topLeftPosX - 2)* GRID_SIZE,
    y = (self.topLeftPosY - 1) * GRID_SIZE,
    w = GRID_SIZE,
    h = self.height * GRID_SIZE
  }
  -- make the left room edge
  local roomEdge = RoomEdge('roomEdgeLeft', roomRect, Direction4.left, 'push')
  roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
  entities:addEntity(roomEdge)
  lume.push(self.entities, roomEdge)
  -- make right room edge
  roomRect.x = (self:getBottomRightPositionX()) * GRID_SIZE
  roomRect.y = (self.topLeftPosY - 1) * GRID_SIZE
  roomEdge = RoomEdge('roomEdgeRight',roomRect, Direction4.right, 'push')
  roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
  entities:addEntity(roomEdge)
  lume.push(self.entities, roomEdge)
  -- make top room edge
  roomRect.x = (self.topLeftPosX - 1) * GRID_SIZE
  roomRect.y = (self.topLeftPosY - 2) * GRID_SIZE
  roomRect.w = self.width * GRID_SIZE
  roomRect.h = GRID_SIZE
  roomEdge = RoomEdge('roomEdgeUp', roomRect, Direction4.up, 'push')
  roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
  entities:addEntity(roomEdge)
  lume.push(self.entities, roomEdge)
  -- make bottom room edge
  roomRect.x = (self.topLeftPosX - 1) * GRID_SIZE
  roomRect.y = (self:getBottomRightPositionY()) * GRID_SIZE
  roomEdge = RoomEdge('roomEdgeDown', roomRect, Direction4.down, 'push')
  roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
  entities:addEntity(roomEdge)  
  lume.push(self.entities, roomEdge)
end

function Room:unload(entities)
  -- remove entities
  lume.each(self.entities, function(entity)
    entities:removeEntity(entity)
  end)
  self.entities = { }
  -- remove tile entities
  for layerIndex, tileLayer in ipairs(self.map:getTileLayers()) do
    for x = self:getTopLeftPositionX(), self:getBottomRightPositionX() do
      for y = self:getTopLeftPositionY(), self:getBottomRightPositionY() do
        local tileData = self.map:getTileData(x, y, layerIndex)
        if tileData then
          entities:removeTileEntity(x, y, layerIndex)
        end
      end
    end
  end
end

function Room:indexInRoom(x, y)
  return self:getTopLeftPositionX() <= x and x <= self:getBottomRightPositionX()
  and self:getTopLeftPositionY() <= y and y <= self:getBottomRightPositionY()
end

function Room:onRoomTransitionRequest(transitionStyle, direction4, playerX, playerY)
  playerX = math.floor(playerX / GRID_SIZE) + 1
  playerY = math.floor(playerY / GRID_SIZE) + 1
  local newRoom = nil
  -- check if there is a room player can transition to
  if direction4 == Direction4.up or direction4 == Direction4.down then
    local y = nil
    if direction4 == Direction4.up then
      y = self.topLeftPosY - 1
    elseif direction4 == Direction4.down then
      y = self:getBottomRightPositionY() + 1
    end
    newRoom = self.map:getRoomContainingIndex(playerX, y)
  elseif direction4 == Direction4.left or direction4 == Direction4.right then
    local x = nil
    if direction4 == Direction4.left then
      x = self.topLeftPosX - 1
    elseif direction4 == Direction4.right then
      x = self:getBottomRightPositionX() + 1
    end
    newRoom = self.map:getRoomContainingIndex(x, playerY)
  else
    error()
  end
  if newRoom ~= nil and newRoom ~= self then
    self:emit('roomTransitionRequest', newRoom, transitionStyle, direction4)
  end
end

return Room
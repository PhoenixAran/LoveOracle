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
    print(self.topLeftPosX, self.topLeftPosY)
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

function Room:getBottomRightPositionY()
  return self.topLeftPosY + self.height - 1
end

function Room:getBottomRightPositionX()
  return self.topLeftPosX + self.width - 1
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
    for x = self:getTopLeftPositionX() + 1, self:getBottomRightPositionX() + 1 do
      for y = self:getTopLeftPositionY() + 1, self:getBottomRightPositionY() + 1 do
        local tileData = self.map:getTileData(x, y, layerIndex)
        if tileData then
          entities:addTileEntity(Tile(tileData, x, y, layerIndex))
        end
      end
    end
  end
  -- add room edges
  -- make left room edge
  local roomAvailable = self.map:indexInRoom(self.topLeftPosX - 1, self.topLeftPosY)
  local roomRect = {
    useBumpCoords = true,
    x = self.topLeftPosX * GRID_SIZE,
    y = (self.topLeftPosY - 1) * GRID_SIZE,
    w = GRID_SIZE,
    h = self.height * GRID_SIZE
  }
  local roomEdge = RoomEdge('roomEdgeLeft', roomRect, Direction4.left, 'push')
  roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
  entities:addEntity(roomEdge)
  lume.push(self.entities, roomEdge)
  -- make right room edge
  roomRect.x = (self:getBottomRightPositionX()) * GRID_SIZE
  roomRect.y = (self.topLeftPosY) * GRID_SIZE
  roomEdge = RoomEdge('roomEdgeRight',roomRect, Direction4.right, 'push')
  roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
  entities:addEntity(roomEdge)
  lume.push(self.entities, roomEdge)
  -- make top room edge
  roomRect.x = (self.topLeftPosX ) * GRID_SIZE
  roomRect.y = (self.topLeftPosY - 1) * GRID_SIZE
  roomRect.w = self.width * GRID_SIZE
  roomRect.h = GRID_SIZE
  roomEdge = RoomEdge('roomEdgeUp', roomRect, Direction4.up, 'push')
  roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
  entities:addEntity(roomEdge)
  lume.push(self.entities, roomEdge)
  -- make bottom room edge
  roomRect.x = (self.topLeftPosX ) * GRID_SIZE
  roomRect.y = (self:getBottomRightPositionY()) * GRID_SIZE
  roomEdge = RoomEdge('roomEdgeDown', roomRect, Direction4.down, 'push')
  roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
  entities:addEntity(roomEdge)
  lume.push(self.entities, roomEdge)
end

function Room:unload(entities)
  error('TODO')
  -- remove entities
  lume.each(entities, function(entity)
    entities:removeEntity(entity)
  end)
  self.entities = { }
  -- remove tile entities
end

function Room:indexInRoom(x, y)
  return self:getTopLeftPositionX() <= x and x <= self:getBottomRightPositionX()
  and self:getTopLeftPositionY() <= y and y <= self:getBottomRightPositionY()
end

return Room
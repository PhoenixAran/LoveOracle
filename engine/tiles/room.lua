local Class = require 'lib.class'
local lume = require 'lib.lume'
local rect = require 'engine.utils.rectangle'
local SignalObject = require 'engine.signal_object'
local TilesetBank = require 'engine.utils.tileset_bank'
local RoomEdge = require 'engine.entities.room_edge'
local Direction4 = require 'engine.enums.direction4'

local GRID_SIZE = 16

local BACKGROUND_LAYER = 1
local FOREGROUND_LAYER = 2
local OBJECT_LAYER = 3

local Room = Class { __includes = SignalObject,
  init = function(self, map, roomData)
    SignalObject.init(self) 
    self:signal('roomTransitionRequested')
    self:signal('mapTransitionRequested')
    self.map = map
    self.name = roomData:getName()
    self.theme = TilesetBank.getTilesetTheme(roomData:getTheme())
    self.topLeftPosX = roomData:getTopLeftPositionX()
    self.topLeftPosY = roomData:getTopLeftPositionY()
    self.sizeX = roomData:getSizeX()
    self.sizeY = roomData:getSizeY()

    -- ids of entities that were killed 
    self.destroyedEntities = { }
    -- ids of tile entities that were destroyed
    self.destroyedTileEntities = { }
  end
}

function Room:getType()
  return 'room'
end

function Room:getName()
  return self.name
end

function Room:getTheme()
  return self.theme
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
  return self.topLeftPosX + self.sizeX - 1
end

function Room:getBottomRightPositionY()
  return self.topLeftPosY + self.sizeY - 1
end

function Room:getBottomRightPosition()
  return self.topLeftPosX + self.sizeX - 1, self.topLeftPosY + self.sizeY - 1
end

function Room:getBottomRightPositionX()
  return self.topLeftPosX + self.sizeX - 1 
end

function Room:getBottomRightPositionY()
  return self.topLeftPosY + self.sizeY - 1
end

function Room:getSizeX()
  return self.sizeX
end

function Room:getSizeY()
  return self.sizeY
end

-- function Room:resetState()
--   lume.clear(self.destroyedEntities)
--   lume.clear(self.destroyedTileEntities)
-- end

function Room:load(entities)
  -- add tiles
  for layerIndex = BACKGROUND_LAYER, FOREGROUND_LAYER do
    local tileLayer = self.map:getLayer(layerIndex)
    assert(tileLayer:getType() == 'tile_layer')
    for x = self:getTopLeftPositionX(), self:getBottomRightPositionX(), 1 do
      for y = self:getTopLeftPositionY(), self:getBottomRightPositionY(), 1 do
   
        local tileGid = tileLayer:getTile(x, y)
        if tileGid then
          local tileData = self.theme:getTile(tileGid)
          entities:addTileEntity(tileData:createTileEntity(layerIndex, x, y))
        end
      end
    end
  end
  -- TODO add entities

  -- add room edges
  -- make left room edge
  local roomAvailable = self.map:indexInRoom(self.topLeftPosX - 2, self.topLeftPosY - 1)
  local roomRect = {
    useBumpCoords = true,
    x = (self.topLeftPosX - 2) * GRID_SIZE,
    y = (self.topLeftPosY - 1) * GRID_SIZE,
    w = GRID_SIZE, 
    h = self.sizeY * GRID_SIZE
  }
  local roomEdge = RoomEdge('roomEdgeLeft', roomRect, Direction4.left, roomAvailable, 'slide')
  entities:addEntity(roomEdge)
  -- make right room edge
  roomRect.x = (self:getBottomRightPositionX()) * GRID_SIZE
  roomRect.y = (self.topLeftPosY - 1) * GRID_SIZE
  roomAvailable = self.map:indexInRoom(self:getBottomRightPositionX(), self.topLeftPosY - 1)
  roomEdge = RoomEdge('roomEdgeRight',roomRect, Direction4.right, roomAvailable, 'slide')
  entities:addEntity(roomEdge)
  -- make top room edge
  roomAvailable = self.map:indexInRoom(self.topLeftPosX - 1, self.topLeftPosY - 2)
  roomRect.x = (self.topLeftPosX - 1) * GRID_SIZE
  roomRect.y = (self.topLeftPosY - 2) * GRID_SIZE
  roomRect.w = self.sizeX * GRID_SIZE
  roomRect.h = GRID_SIZE
  roomEdge = RoomEdge('roomEdgeUp', roomRect, Direction4.up, roomAvailable, 'slide')
  entities:addEntity(roomEdge)
  -- make bottom room edge
  roomAvailable = self.map:indexInRoom(self.topLeftPosX - 1, self:getBottomRightPositionY())
  roomRect.x = (self.topLeftPosX - 1) * GRID_SIZE
  roomRect.y = (self:getBottomRightPositionY()) * GRID_SIZE
  roomEdge = RoomEdge('roomEdgeDown', roomRect, Direction4.down, roomAvailable, 'slide')
  entities:addEntity(roomEdge)
end


-- this will only keep track of the entities declared in room data
function Room:onEntityDestroyed()
  -- If it's a tile entity, record it to list of destroyed entitites
end

-- pass signal from RoomEdge to whoever is listening
function Room:onRequestTransitionRequest()
  self:emit('roomTransitionRequested')
end

-- pass signal from MapLoadingZone to whoever is listening
function Room:onMapTransitionRequested()
  self:emit('mapTransitionRequested')
end

function Room:indexInRoom(x, y)
  local rx1, ry1 = self:getTopLeftPosition()
  local rx2, ry2 = self:getBottomRightPosition()
  return rx1 <= x and x <= rx2 and ry1 <= y and y <= ry2
end

function Room:getType()
  return 'room'
end

function Room:getRoomData()
  return self.roomData
end

return Room
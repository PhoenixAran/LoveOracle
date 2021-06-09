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
    self:signal('roomTransitionRequest')
    self:signal('mapTransitionRequest')
    self.map = map
    self.name = roomData:getName()
    self.theme = TilesetBank.getTilesetTheme(roomData:getTheme())
    self.topLeftPosX = roomData:getTopLeftPositionX()
    self.topLeftPosY = roomData:getTopLeftPositionY()
    self.sizeX = roomData:getSizeX()
    self.sizeY = roomData:getSizeY()

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
          local tileEntity = tileData:createTileEntity(layerIndex, x, y)
          entities:addTileEntity(tileEntity)
        end
      end
    end
  end
  -- TODO add entities

  -- add room edges
  -- make left room edge
  local roomAvailable = self.map:indexInRoom(self.topLeftPosX - 1, self.topLeftPosY)
  local roomRect = {
    useBumpCoords = true,
    x = (self.topLeftPosX - 2) * GRID_SIZE,
    y = (self.topLeftPosY - 1) * GRID_SIZE,
    w = GRID_SIZE, 
    h = self.sizeY * GRID_SIZE
  }
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
  roomRect.w = self.sizeX * GRID_SIZE
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
  lume.each(self.entities, function(entity)
    entities:removeEntity(entity)
  end)
  self.entities = {}
  for layerIndex = BACKGROUND_LAYER, FOREGROUND_LAYER do
    local tileLayer = self.map:getLayer(layerIndex)
    assert(tileLayer:getType() == 'tile_layer')
    for x = self:getTopLeftPositionX(), self:getBottomRightPositionX(), 1 do
      for y = self:getTopLeftPositionY(), self:getBottomRightPositionY(), 1 do
        if tileLayer:getTile(x, y) then
          entities:removeTileEntity(layerIndex, x, y)
        end
      end
    end
  end
end


-- this will only keep track of the entities declared in room data
function Room:onEntityDestroyed(entity)
  -- TODO function
  -- If it's a tile entity, record it to list of destroyed entitites
end

-- pass signal from RoomEdge to whoever is listening
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
  if newRoom then
    self:emit('roomTransitionRequest', newRoom, transitionStyle, direction4)
  end
end

-- pass signal from MapLoadingZone to whoever is listening
function Room:onMapTransitionRequested()
  self:emit('mapTransitionRequest')
end

function Room:indexInRoom(x, y)
  return self:getTopLeftPositionX() <= x and x <= self:getBottomRightPositionX() 
  and self:getTopLeftPositionY() <= y and y <= self:getBottomRightPositionY()
end

function Room:getType()
  return 'room'
end

function Room:getRoomData()
  return self.roomData
end

return Room
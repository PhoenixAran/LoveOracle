local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'
local RoomEdge = require 'engine.entities.room_edge'
local Direction4 = require 'engine.enums.direction4'
local Tile = require 'engine.tiles.tile'

local GRID_SIZE = require('constants').GRID_SIZE

---@class Room : SignalObject
---@field roomData RoomData
---@field map Map
---@field topLeftPosX integer
---@field topLeftPosY integer
---@field width integer
---@field height integer
---@field entities Entity[]
---@field destroyedEntites integer[]
---@field destroyedTileEntities integer[]
---@field animatedTiles table<integer, TileData>
---@field animatedTilesCollectionCreated boolean
local Room = Class { __includes = SignalObject,
  ---@param self table
  ---@param map Map
  ---@param roomData RoomData
  init = function(self, map, roomData)
    SignalObject.init(self)
    self:signal('roomTransitionRequest')
    self:signal('mapTransitionRequest')

    self.roomData = roomData
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

    -- animated tiles keyd with the TileData instance Id for the given map
    -- note that this collection is created then the load function is called
    self.animatedTiles = { }
    self.animatedTilesCollectionCreated = false
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

---@param entities Entities
function Room:load(entities)
  --[[
    Connect to entities signals
  ]]

  --[[
    STEP 2: Add Tiles
  ]]
  for layerIndex, tileLayer in ipairs(self.map:getTileLayers()) do
    for x = self:getTopLeftPositionX(), self:getBottomRightPositionX() do
      for y = self:getTopLeftPositionY(), self:getBottomRightPositionY() do
        local tileData, gid = self.map:getTileData(x, y, layerIndex)
        if tileData then
          local tile = Tile(tileData, lume.count(entities) + 1, x, y, layerIndex)
          tile:initTransform()
          entities:addTileEntity(tile)
          if (not self.animatedTilesCollectionCreated) and tile:isAnimated() then
            self.animatedTiles[tileData.instanceId] = tileData
          end
        end
      end
    end
  end

  self.animatedTilesCollectionCreated = true

  --[[
    STEP 3: Make room edges
  ]]
  -- helper function
  local function createRoomEdge(name, x, y, w, h, direction)
    local roomEdge = RoomEdge {
      name = name,
      useBumpCoords = true,
      x = x,
      y = y,
      w = w,
      h = h,
      direction4 = direction,
      transitionStyle = 'push'  -- TODO support other styles
    }
    roomEdge:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
    entities:addEntity(roomEdge)
    lume.push(self.entities, roomEdge)
  end

  createRoomEdge('roomEdgeLeft', (self.topLeftPosX - 2) * GRID_SIZE, (self.topLeftPosY - 1) * GRID_SIZE, GRID_SIZE, self.height * GRID_SIZE, Direction4.left)
  createRoomEdge('roomEdgeRight', self:getBottomRightPositionX() * GRID_SIZE, (self.topLeftPosY - 1) * GRID_SIZE, GRID_SIZE, self.height * GRID_SIZE, Direction4.right)
  createRoomEdge('roomEdgeUp', (self.topLeftPosX - 1) * GRID_SIZE, (self.topLeftPosY - 2) * GRID_SIZE, self.width * GRID_SIZE, GRID_SIZE, Direction4.up)
  createRoomEdge('roomEdgeDown', (self.topLeftPosX - 1) * GRID_SIZE, self:getBottomRightPositionY() * GRID_SIZE, self.width * GRID_SIZE, GRID_SIZE, Direction4.down)

  --[[
    STEP 4: Make room edges
  ]]
  for _, entitySpawner in ipairs(self.roomData.entitySpawners) do
    local entity = entitySpawner:createEntity()
  end
end

---@param entities Entities
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

function Room:updateAnimatedTiles(dt)
  for _, tile in pairs(self.animatedTiles) do
    tile.sprite:update(dt)
  end
end

return Room
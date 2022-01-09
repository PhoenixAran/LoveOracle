local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'
local RoomEdge = require 'engine.entities.room_edge'
local Direction4 = require 'engine.enums.direction4'

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
  return self.topLeftPosX + self.sizeX - 1
end

function Room:getBottomRightPositionY()
  return self.topLeftPosY + self.sizeY - 1
end

function Room:getBottomRightPositionX()
  return self.topLeftPosX + self.sizeX - 1 
end

function Room:getWidth()
  return self.width
end

function Room:getHeight()
  return self.height
end

function Room:load(entities)
  -- add tiles

  -- add room edges
  -- make left room edge
  -- make right room edge
  -- make top room edge
  -- make bottom room edge
end

function Room:unload(entities)
  -- remove entities
  lume.each(entities, function(entity)
    entities:removeEntity(entity)
  end)
  self.entities = { }
  -- remove tile entities
end

return Room
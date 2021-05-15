local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local BitTag = require 'engine.utils.bit_tag'
local Physics = require 'engine.physics'
local TablePool = require 'engine.utils.table_pool'
local vector = require 'lib.vector'
local lume = require 'lib.lume'

local Direction4 = require 'engine.enums.direction4'

local RoomEdge = Class { __includes = Entity,
  init = function(self, name, rect, direction4, canTransition, transitionStyle)
    Entity.init(self, name, true, false, rect)
    self.direction4 = direction4
    -- you dont want to be able to transition if there is no room to transition to
    -- mainly used for rooms at the edge of the map
    self.canTransition = canTransition
    self.transitionStyle = transitionStyle
    self:signal('roomTransitionRequest')

    self:setPhysicsLayer('room_edge')
    self:setCollidesWithLayer('player')
  end
}

function RoomEdge:getType()
  return 'room_edge'
end

function RoomEdge:getCollisionTag()
  return 'room_edge'
end

function RoomEdge:canRoomTransition(playerDirection4)
  return self.canTransition and playerDirection4 == self.direction4
end

function RoomEdge:requestRoomTransition()
  self:emit('roomTransitionRequest', self.transitionStyle, self.direction4)
end

function RoomEdge:draw()
  local x, y = self:getBumpPosition()
  love.graphics.setColor(0, 0, 160 / 255, 180 / 255)
  love.graphics.rectangle('fill', x, y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

return RoomEdge
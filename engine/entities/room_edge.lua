local Class = require 'lib.class'
local Entity = require 'engine.entities'
local BitTag = require 'engine.utils.bit_tag'
local Physics = require 'engine.physics'
local TablePool = require 'engine.utils.table_pool'
local vector = require 'lib.vector'
local lume = require 'lib.lume'

local Direction4 = require 'engine.enums.direction4'

local RoomEdge = Class { __includes = Entity,
  init = function(self, rect, direction4, transitionStyle)
    Entity.init(self, nil, true, false, rect)
    self.direction4 = direction4
    self.transitionStyle = transitionStyle
    self.signal('roomTransitionRequest')

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
  return playerDirection4 == self.direction4
end

function RoomEdge:requestRoomTransition()
  self:emit('roomTransitionRequest', self.transitionStyle, self.direction4)
end

return RoomEdge
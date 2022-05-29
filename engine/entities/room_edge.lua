local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local Physics = require 'engine.physics'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local TablePool = require 'engine.utils.table_pool'
local vector = require 'lib.vector'
local lume = require 'lib.lume'

local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'

---@class RoomEdge : Entity
---@field canTransition boolean
---@field direction4 integer
---@field transitionStyle string
local RoomEdge = Class { __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)
    self.direction4 = args.direction4
    -- you dont want to be able to transition if there is no room to transition to
    -- mainly used for rooms ad the edge of you dont put a wall there for whatever reason
    self.canTransition = false
    self.transitionStyle = args.transitionStyle or 'push'
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

-- called by player in Player:checkRoomTransitions()
-- todo should probably have method signature as (x, y) so we can measure the angle
---@param dir8 integer
function RoomEdge:canRoomTransition(dir8)
  if self.direction4 == Direction4.up then
    return dir8 == Direction8.up or dir8 == Direction8.upLeft or dir8 == Direction8.upRight
      or dir8 == Direction8.left or dir8 == Direction8.right -- allow these for slight angles on analogs
  elseif self.direction4 == Direction4.down then
    return dir8 == Direction8.down or dir8 == Direction8.downLeft or dir8 == Direction8.downRight
      or dir8 == Direction8.left or dir8 == Direction8.right
  elseif self.direction4 == Direction4.left then
    return dir8 == Direction8.left or dir8 == Direction8.upLeft or dir8 == Direction8.downLeft
      or dir8 == Direction8.up or dir8 == Direction8.down
  elseif self.direction4 == Direction4.right then
    return dir8 == Direction8.right or dir8 == Direction8.upRight or dir8 == Direction8.downRight
      or dir8 == Direction8.up or dir8 == Direction8.down
  else
    error()
  end
end

---@param playerX number
---@param playerY number
function RoomEdge:requestRoomTransition(playerX, playerY)
  self:emit('roomTransitionRequest', self.transitionStyle, self.direction4, playerX, playerY)
end

function RoomEdge:debugDraw()
  local x, y = self:getBumpPosition()
  love.graphics.setColor(0, 0, 160 / 255, 100 / 255)
  love.graphics.rectangle('fill', x, y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

return RoomEdge
local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local GameState = require 'engine.control.game_state'
local Entities = require 'engine.entities.entities'

local GRID_SIZE = 16
local RoomControl = Class { __includes = GameState,
  init = function(self, map, player, camera)
    GameState.init(self)
    self.player = player
    self.camera = camera
    self.map = map

    self.entities = Entities()
    self.entities:setUpTileEntityCollection(map:getSizeX(), map:getSizeY(), map:getLayerCount())

    self.previousRooms = { }
    self.currentRoom = nil
    self.roomEventStack = nil
    self.allowRoomTransition = true
  end
}

function RoomControl:getType()
  return 'room_control'
end

function RoomControl:getMap()
  return self.map
end

function RoomControl:getCamera()
  return self.camera
end

function RoomControl:getPlayer()
  return self.player
end

function RoomControl:getEntities()
  return self.entities
end

function RoomControl:canRoomTransition()
  return self.allowRoomTransition
end

function RoomControl:enableRoomTransition(enable)
  self.allowRoomTransition = enable
end

function RoomControl:connectToRoomSignals(room)
  room:connect('roomTransitionRequest', self, 'onRoomTransitionRequest')
end

function RoomControl:disconnectFromRoomSignals(room)
  room:disconnect('roomTransitionRequest', self, 'onRoomTransitionRequest')
end

function RoomControl:onBegin()
  local map = self:getMap()
  self.entities:setPlayer(self.player)
end

function RoomControl:onEnd()
  self.entities:release()
  self:release()
end

function RoomControl:update(dt)
  -- TODO check for pause here
  self.entities:update(dt)
  self.camera:update(dt)
  self.camera:follow(self.player:getPosition())
end

function RoomControl:draw()
  self.camera:attach()
  local x = self.camera.x - self.camera.w / 2
  local y = self.camera.y - self.camera.h / 2
  local w = self.camera.w
  local h = self.camera.h
  self.entities:drawTileEntities(x, y, w, h)
  self.entities:drawEntities()
  self.camera:detach()
end

function RoomControl:onRoomTransitionRequest(newRoom, transitionStyle, direction4)
  print('RoomControl:onRoomTransitionRequest', newRoom, transitionStyle, direction4)
end

return RoomControl
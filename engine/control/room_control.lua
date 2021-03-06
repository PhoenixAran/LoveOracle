local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local GameState = require 'engine.control.game_state'
local RoomStateStack = require 'engine.control.room_state_stack'
local Entities = require 'engine.entities.entities'

local GRID_SIZE = 16
local RoomTransitionState = require 'engine.control.game_states.room_states.room_transition_state'

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
    self.allowRoomTransition = true
    self.roomStateStack = RoomStateStack(self)
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

function RoomControl:pushState(roomState)
  self.roomStateStack:pushState(roomState)
end

function RoomControl:popState()
  self.roomStateStack:popState()
end

-- note that this wont handle room transtioning and loading
-- This will only set the reference the variable currentRoom, and push 
-- the old room in the old table
function RoomControl:setCurrentRoom(room)
  self:disconnectFromRoomSignals(self.currentRoom)
  lume.push(self.previousRooms, self.currentRoom)
  self.currentRoom = room
  self:connectToRoomSignals(self.currentRoom)
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
  local roomState = self.roomStateStack:getCurrentState()
  if roomState then
    roomState:update(dt)
  end
end

function RoomControl:draw()
  local roomState = self.roomStateStack:getCurrentState()
  if roomState then
    roomState:draw()
  end
end

function RoomControl:onRoomTransitionRequest(newRoom, transitionStyle, direction4)
  if self:canRoomTransition() then
    self:pushState(RoomTransitionState(self.currentRoom, newRoom, transitionStyle, direction4))
  end
end

return RoomControl
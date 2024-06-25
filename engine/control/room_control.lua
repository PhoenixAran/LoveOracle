local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local GameState = require 'engine.control.game_state'
local GameStateStack = require 'engine.control.game_state_stack'
local Entities = require 'engine.entities.entities'

local GRID_SIZE = require('constants').GRID_SIZE
local RoomTransitionState = require 'engine.control.game_states.room_states.room_transition_state'

---@class RoomControl : GameState
---@field player Player
---@field camera any
---@field map Map
---@field entities Entities
---@field previousRooms Room[]
---@field currentRoom Room?
---@field allowRoomTransition boolean
---@field roomStateStack GameStateStack
local RoomControl = Class { __includes = GameState,
  init = function(self, map, player)
    GameState.init(self)
    self.player = player
    self.map = map

    self.entities = Entities()
    self.entities:setUpTileEntityCollection(map:getWidth(), map:getHeight(), map:getTileLayerCount())

    self.previousRooms = { }
    self.currentRoom = nil
    self.allowRoomTransition = true
    self.roomStateStack = GameStateStack(self)
  end
}

function RoomControl:getType()
  return 'room_control'
end

function RoomControl:getMap()
  return self.map
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

---sets if room control should allow room transitions
---@param enable boolean
function RoomControl:enableRoomTransition(enable)
  self.allowRoomTransition = enable
end

--- push a room state onto the state stack
---@param roomState GameState
function RoomControl:pushState(roomState)
  self.roomStateStack:pushState(roomState)
end


--- pop room state from state stack
function RoomControl:popState()
  self.roomStateStack:popState()
end

--- note that this wont handle room transtioning and loading
--- This will only set the reference the variable currentRoom, and push
--- the old room in the old table
---@param room Room
function RoomControl:setCurrentRoom(room)
  self:disconnectFromRoomSignals(self.currentRoom)
  lume.push(self.previousRooms, self.currentRoom)
  self.currentRoom = room
  self:connectToRoomSignals(self.currentRoom)
end

---@param room Room
function RoomControl:connectToRoomSignals(room)
  room:connect('room_transition_request', self, 'onRoomTransitionRequest')
end

---@param room Room
function RoomControl:disconnectFromRoomSignals(room)
  room:disconnect('room_transition_request', self, 'onRoomTransitionRequest')
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

---@param tile Tile
function RoomControl:isTopTile(tile)
  return self.entities:isTopTile(tile)
end

---function thats gets called when a Room's roomTransitionRequest signal is emitted
---@param newRoom Room
---@param transitionStyle string
---@param direction4 integer
function RoomControl:onRoomTransitionRequest(newRoom, transitionStyle, direction4)
  if self:canRoomTransition() then
    self:pushState(RoomTransitionState(self.currentRoom, newRoom, transitionStyle, direction4))
  end
end

return RoomControl
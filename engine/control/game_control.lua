local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local SignalObject = require 'engine.signal_object'
local Entities = require 'engine.entities.entities'
local Inventory = require 'engine.control.inventory'
local GameStateStack = require 'engine.control.game_state_stack'
local Camera = require 'lib.camera'
local GameConfig = require 'game_config'

local RoomControl = require 'engine.control.room_control'
local RoomNormalState = require 'engine.control.game_states.room_states.room_normal_state'

local Singletons = require 'engine.singletons'
local monocle = Singletons.monocle

local GRID_SIZE = 16

---@class GameControl
---@field inventory Inventory
---@field player Player
---@field camera any
---@field map Map
---@field roomControl RoomControl
---@field gameStateStack GameStateStack
local GameControl = Class { __includes = SignalObject,
  init = function(self)
    self.inventory = Inventory()
    self.player = nil
    local w = GameConfig.window.monocleConfig.windowWidth
    local h = GameConfig.window.monocleConfig.windowHeight - 16
    self.camera = Camera(w/2,h/2, w, h)
    self.camera:setFollowStyle('NO_DEADZONE')
    self.map = nil
    self.roomControl = nil
    self.gameStateStack = GameStateStack(self)
  end
}

function GameControl:getType()
  return 'game_control'
end

---@return RoomControl
function GameControl:getRoomControl()
  return self.roomControl
end

---@return Inventory
function GameControl:getInventory()
  return self.inventory
end

---@return Player
function GameControl:getPlayer()
  return self.player
end

---@param player Player
function GameControl:setPlayer(player)
  self.player = player
end

---@return Map
function GameControl:getMap()
  return self.map
end

---@param map Map    
function GameControl:setMap(map)
  self.map = map
end

---@return any
function GameControl:getCamera()
  return self.camera
end

---@param camera any
function GameControl:setCamera(camera)
  self.camera = camera
end

--- creates the initial room control state. called when game starts
---@param room Room
---@param spawnIndexX integer
---@param spawnIndexY integer
function GameControl:setInitialRoomControlState(room, spawnIndexX, spawnIndexY)
  self:getPlayer():setPosition(spawnIndexX * GRID_SIZE, spawnIndexY * GRID_SIZE)
  self.roomControl = RoomControl(self:getMap(), self:getPlayer(), self:getCamera())
  -- man handle room control for initial startup
  self.roomControl.currentRoom = room
  self.roomControl.player:setPosition(spawnIndexX * GRID_SIZE, spawnIndexY * GRID_SIZE)
  self.roomControl.currentRoom:load(self.roomControl.entities)
  self.roomControl:connectToRoomSignals(room)
  self.roomControl:pushState(RoomNormalState())

  local x1, y1 = room:getTopLeftPosition()
  local x2, y2 = room:getBottomRightPosition()
  x1 = x1 - 1
  y1 = y1 - 1
  x1, y1 = vector.mul(GRID_SIZE, x1, y1)
  x2, y2 = vector.mul(GRID_SIZE, x2, y2)
  self:getCamera():setBounds(x1, y1, x2 - x1, y2 - y1)
  -- push room control state so user can actually start playing
  self:pushState(self.roomControl)
end

function GameControl:update(dt)
  local gameState = self.gameStateStack:getCurrentState()
  if gameState then
    gameState:update(dt)
  end
end

function GameControl:draw()
  monocle:begin()
  local gameState = self.gameStateStack:getCurrentState()
  if gameState then
    gameState:draw()
  end
  monocle:finish()
end

---@param gameState GameState
function GameControl:pushState(gameState)
  self.gameStateStack:pushState(gameState)
end

---@return GameState
function GameControl:popState()
  return self.gameStateStack:popState()
end


function GameControl:release()
  -- TODO release signal object members
  SignalObject.release(self)
end

return GameControl
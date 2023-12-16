local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local SignalObject = require 'engine.signal_object'
local Entities = require 'engine.entities.entities'
local Inventory = require 'engine.control.inventory'
local GameStateStack = require 'engine.control.game_state_stack'
local GameConfig = require 'game_config'
local Consts = require 'constants'
local Camera = require 'engine.camera'

local RoomControl = require 'engine.control.room_control'
local RoomNormalState = require 'engine.control.game_states.room_states.room_normal_state'

local Singletons = require 'engine.singletons'
local DisplayHandler = require 'engine.display_handler'

local console = require 'lib.console'

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
    local w = GameConfig.window.displayConfig.gameWidth
    local h = GameConfig.window.displayConfig.gameHeight - Consts.GRID_SIZE
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

--- creates the initial room control state. called when game starts
---@param room Room
---@param spawnIndexX integer?
---@param spawnIndexY integer?
function GameControl:setInitialRoomControlState(room, spawnIndexX, spawnIndexY)
  self.roomControl = RoomControl(self:getMap(), self:getPlayer())
  self:getPlayer():setPosition(spawnIndexX * Consts.GRID_SIZE, spawnIndexY * Consts.GRID_SIZE)
  self:getPlayer():markRespawn()
  self.roomControl.player:setPosition(spawnIndexX * Consts.GRID_SIZE, spawnIndexY * Consts.GRID_SIZE)
  -- man handle room control for initial startup
  self.roomControl.currentRoom = room

  self.roomControl.currentRoom:load(self.roomControl.entities)
  self.roomControl:connectToRoomSignals(room)
  self.roomControl:pushState(RoomNormalState())

  local x1, y1 = room:getTopLeftPosition()
  local x2, y2 = room:getBottomRightPosition()
  
  x1 = x1 - 1
  y1 = y1 - 1
  x1, y1 = vector.mul(Consts.GRID_SIZE, x1, y1)
  x2, y2 = vector.mul(Consts.GRID_SIZE, x2, y2)
  Camera.setFollowTarget(self:getPlayer())
  Camera.setLimits(x1, x2, y1, y2)
  -- push room control state so user can actually start playing
  self:pushState(self.roomControl)

  -- set singleton
  Singletons.roomControl = self.roomControl
end

function GameControl:update(dt)
  local gameState = self.gameStateStack:getCurrentState()
  if gameState then
    gameState:update(dt)
  end
end

function GameControl:draw()
  DisplayHandler.push()
  local gameState = self.gameStateStack:getCurrentState()
  if gameState then
    gameState:draw()
  end
  DisplayHandler.pop()
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
---@diagnostic disable-next-line: param-type-mismatch
  SignalObject.release(self)
end

return GameControl
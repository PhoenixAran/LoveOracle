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

local GRID_SIZE = 16

local GameControl = Class { __includes = SignalObject,
  init = function(self)
    self.inventory = Inventory()  
    self.player = nil

    local w = GameConfig.window.monocleConfig.windowWidth
    local h = GameConfig.window.monocleConfig.windowHeight
    self.camera = Camera(w/2,h/2 , w, h)
    self.camera:setFollowStyle('NO_DEADZONE')

    self.map = nil
    self.roomControl = nil
    self.gameStateStack = GameStateStack(self)
  end
}

function GameControl:getType()
  return 'game_control'
end

function GameControl:getRoomControl()
  return self.roomControl
end

function GameControl:getInventory()
  return self.inventory
end

function GameControl:getPlayer()
  return self.player
end

function GameControl:setPlayer(player)
  self.player = player
end

function GameControl:getMap()
  return self.map
end

function GameControl:setMap(map)
  self.map = map
end

-- creates the initial room control state
-- called when game starts
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
  x1 = x1 - 1
  y1 = y1 - 1
  local x2, y2 = room:getBottomRightPosition()
  x1, y1 = vector.mul(GRID_SIZE, x1, y1)
  x2, y2 = vector.mul(GRID_SIZE, x2, y2)
  self:getCamera():setBounds(x1, y1, x2 - x1, y2 - y1)  

  -- push room control state so user can actually start playing
  self:pushState(self.roomControl)
end

function GameControl:getCamera()
  return self.camera
end

function GameControl:setCamera(camera)
  self.camera = camera
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

function GameControl:pushState(gameState)
  self.gameStateStack:pushState(gameState)
end

function GameControl:popState()
  return self.gameStateStack:popState()
end

function GameControl:release()
  -- TODO release signal object members
  SignalObject.release(self)
end

return GameControl
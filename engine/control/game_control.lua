local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local SignalObject = require 'engine.signal_object'
local Entities = require 'engine.entities.entities'
local Inventory = require 'engine.control.inventory'
local GameStateStack = require 'engine.control.game_state_stack'
local Camera = require 'lib.camera'
local GameConfig = require 'game_config'

local RoomNormalState = require 'engine.control.game_states.room_normal_state'
local GRID_SIZE = 16

local GameControl = Class { __includes = SignalObject,
  init = function(self)
    self.inventory = Inventory()  
    self.player = nil
    local w = GameConfig.window.monocleConfig.windowWidth
    local h = GameConfig.window.monocleConfig.windowHeight
    self.camera = Camera(w/2,h/2 , w, h)
    --self.camera:setFollowStyle('SCREEN_BY_SCREEN')

    self.entities = Entities()
    self.map = nil
    self.previousRooms = { }
    self.currentRoom = nil
    self.gameStateStack = GameStateStack(self)
  end
}

function GameControl:getType()
  return 'game_control'
end

function GameControl:getInventory()
  return self.inventory
end

function GameControl:getPlayer()
  return self.player
end

function GameControl:setPlayer(player)
  self.player = player
  self.entities:setPlayer(player)
end

function GameControl:getMap()
  return self.map
end

function GameControl:setMap(map)
  self.map = map
  self.entities:setUpTileEntityCollection(map.sizeX, map.sizeY, map.layerCount)
end

-- sets up the initial state so the user can actually start playing the game
function GameControl:setupInitialRoomNormalState()
  -- TODO declare initial room and spawn location in MAP
  local map = self.map
  local initialRoom = lume.first(map:getRooms())
  local roomNormalState = RoomNormalState(initialRoom)
  local spawnIndexX, spawnIndexY = 1, 1
  self.player:setPosition(spawnIndexX * GRID_SIZE, spawnIndexY * GRID_SIZE)
  initialRoom:load(self.entities)
  self:pushState(RoomNormalState(initalRoom))
end

function GameControl:getCamera()
  return self.camera
end

function GameControl:setCamera(camera)
  self.camera = camera
  self.entities:setCamera(camera)
end

-- return Entities object
function GameControl:getEntities()
  return self.entities
end

function GameControl:updateEntities(dt)
  self.entities:update(dt)
end

function GameControl:drawTileEntities(x, y, w, h)
  self.entities:drawTileEntities(x, y, w, h)
end

function GameControl:drawEntities()
  self.entities:drawEntities()
end

-- update the tileset animations
function GameControl:updateTileAnimations(dt)
  -- TODO Update tile animations
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

function GameControl:onRoomTransitionRequest(room, transitionStyle, direction4)
  -- TODO Push room transition state on the stack
  
end

function GameControl:onMapTransitionRequest()
  -- TODO Push map transiton state on the stack
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
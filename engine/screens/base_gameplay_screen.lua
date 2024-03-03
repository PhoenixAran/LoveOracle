local Class = require 'lib.class'
local GameConfig = require 'game_config'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local GameControl = require 'engine.control.game_control'
local Map = require 'engine.tiles.map'
local BaseScreen = require 'engine.screens.base_screen'
local Physics = require 'engine.physics'
local Player = require 'engine.player.player'
local Input = require('engine.singletons').input
local Singletons = require 'engine.singletons'
local console = require 'lib.console'
local Consts = require 'constants'
local FileHelper = require 'engine.utils.file_helper'

-- base screen will set up the game control class for you
---@class BaseGameplayScreen : BaseScreen
---@field gameControl GameControl
---@field initialMap string
local BaseGameplayScreen = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.gameControl = nil
    self.initialRoom = 'initial_room.tmj'
  end
}

function BaseGameplayScreen:getType()
  return 'base_gameplay_screen'
end

function BaseGameplayScreen:enter(prev, ...)
  -- TODO stop hardcoding the positions and map
  -- TODO remove me
  local args = {...}
  local mapName = nil
  if args[1] then
    self.initialRoom = FileHelper.getFileNameWithoutPath(args[1])
    love.log.trace(('Testing map %s'):format(self.initialRoom))
  end
  self.gameControl = GameControl()

  -- TODO init player based off save file and actual spawn point
  local player = Player({name = 'player'})
  player:initTransform()

  self.gameControl:setPlayer(player)
  local map = Map('movement_test.tmj')
  self.gameControl:setMap(map)
  local spawnX, spawnY = 0,0
  if args[1] then
    -- map file was specified, indicating that we are in a test run
    spawnX, spawnY = map:getTestSpawnPosition()
  else
    -- TODO when game save is done. Retrieve the player's save file spawn point
    -- love.window.showMessageBox('Warning', 'Game launched without given testmap file location. Use tilededitor to launch game')
    -- love.event.quit()
  end

  local initialRoom = map:getRoomContainingIndex(vector.add(1, 1, vector.div(Consts.GRID_SIZE, spawnX, spawnY)))
  assert(initialRoom, string.format('Initial player map position (%d,%d) not in room', spawnX, spawnY))
  self.gameControl:setInitialRoomControlState(initialRoom, spawnX, spawnY)
  Singletons.gameControl = self.gameControl
end

function BaseGameplayScreen:update(dt)
  if console.active then
    console.update(dt)
  else
    Input:update(dt)
    self.gameControl:update(dt)
  end
end

function BaseGameplayScreen:draw()
  self.gameControl:draw()
  if console.active then
    console.draw()
  end
end

return BaseGameplayScreen
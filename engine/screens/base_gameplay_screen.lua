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
local BaseGameplayScreen = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.gameControl = nil
  end
}

function BaseGameplayScreen:getType()
  return 'base_gameplay_screen'
end

---enter callback for the base gameplay screen
---@param prev any
---@param ... unknown vardict args for gameplay screen. first element should be the map name
function BaseGameplayScreen:enter(prev, ...)
  -- TODO stop hardcoding the positions and map

  local args = {...}
  local mapFile = 'movement_test.tmj'
  if args[1] then
    mapFile = FileHelper.getFileNameWithoutPath(args[1])
    love.log.debug(('Testing map %s'):format(mapFile))
  end
  self.gameControl = GameControl()

  -- TODO init player based off save file and actual spawn point
  local player = Player({name = 'player'})
  player:initTransform()

  -- TODO set up inventory
  local Sword = require 'engine.items.weapons.item_sword'
  local sword = Sword({name = 'sword'})
  sword.useButtons = { 'y' }
  player:equipItem(sword)

  self.gameControl:setPlayer(player)
  local map = Map(mapFile)
  self.gameControl:setMap(map)
  local spawnX, spawnY = 24,24
  if args[1] then
    -- map file was specified, indicating that we are in a test run
    spawnX, spawnY = map:getTestSpawnPosition()
  else
    -- TODO when game save is done. Retrieve the player's save file spawn point
    -- love.window.showMessageBox('Warning', 'Game launched without given testmap file location. Use tilededitor to launch game')
    -- love.event.quit()
  end
  local spawnIndexX, spawnIndexY = vector.add(1, 1, vector.div(Consts.GRID_SIZE, spawnX, spawnY))
  spawnIndexX, spawnIndexY = math.floor(spawnIndexX), math.floor(spawnIndexY)
  local initialRoom = map:getRoomContainingIndex(spawnIndexX, spawnIndexY)
  assert(initialRoom, string.format('Initial player map position (%d,%d) not in room', spawnIndexX, spawnIndexY))
  self.gameControl:setInitialRoomControlState(initialRoom, spawnX, spawnY)
  Singletons.gameControl = self.gameControl
end

function BaseGameplayScreen:update()
  local dt = love.time.dt
  if console.active then
    console.update(dt)
  else
    Input:update(dt)
    self.gameControl:update()
  end
end

function BaseGameplayScreen:draw()
  self.gameControl:draw()
  self:drawFPS()
  if console.active then
    console.draw()
  end
end


return BaseGameplayScreen
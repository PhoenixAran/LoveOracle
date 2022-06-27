local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local GameControl = require 'engine.control.game_control'
local Map = require 'engine.tiles.map'
local BaseScreen = require 'engine.screens.base_screen'
local Physics = require 'engine.physics'
local Player = require 'engine.player.player'
local Input = require('engine.singletons').input
local Singletons = require 'engine.singletons'
-- base screen will set up the game control class for you
---@class BaseGameplayScreen : BaseScreen
---@field gameControl GameControl
---@field initialMap string
local BaseGameplayScreen = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.gameControl = nil
    self.initialMap = 'test_map_1.json'
  end
}

function BaseGameplayScreen:getType()
  return 'base_gameplay_screen'
end

function BaseGameplayScreen:enter(prev, ...)
  self.gameControl = GameControl()
  self.gameControl:setPlayer(Player({name = 'player', x = 30, y = 30, w = 16, h = 16 }))
  local map = Map('test_map_1.json')
  self.gameControl:setMap(map)
  -- TODO implement designated player spawn from Tiled editor
  local mapIndexX, mapIndexY = vector.div(16, self.gameControl:getPlayer().x, self.gameControl:getPlayer().y)
  mapIndexX, mapIndexY = math.floor(mapIndexX), math.floor(mapIndexY)
  local initialRoom = map:getRoomContainingIndex(mapIndexX, mapIndexY)
  assert(initialRoom, 'Initial player position not in room')
  self.gameControl:setInitialRoomControlState(initialRoom, 3, 3)
  Singletons.gameControl = self.gameControl
end

function BaseGameplayScreen:update()

end

return BaseGameplayScreen
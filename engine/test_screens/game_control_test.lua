local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local GameControl = require 'engine.control.game_control'
local Map = require 'engine.tiles.map'
local BaseScreen = require 'engine.screens.base_screen'
local Physics = require 'engine.physics'
local Player = require 'engine.player.player'


local GameControlTest = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.gameControl = nil
  end
}

function GameControlTest:getType()
  return 'game_control_test'
end

function GameControlTest:enter(prev, ...)
  self.gameControl = GameControl()
  self.gameControl:setPlayer(Player('player', true, true, { x = 30, y = 30, w = 16, h = 16 }))
  local map = Map('test_map_1.json')
  self.gameControl:setMap(map)
  -- TODO implement designated player spawn from Tiled editor
  local mapIndexX, mapIndexY = vector.div(16, self.gameControl:getPlayer().x, self.gameControl:getPlayer().y)
  mapIndexX, mapIndexY = math.floor(mapIndexX), math.floor(mapIndexY)
  local initialRoom = map:getRoomContainingIndex(mapIndexX, mapIndexY)
  assert(initialRoom, 'Initial player position not in room')
  self.gameControl:setInitialRoomControlState(initialRoom, 3, 3)
end

function GameControlTest:update(dt)
  self.gameControl:update(dt)
end

function GameControlTest:draw()
  self.gameControl:draw()
  self:drawFPS()
end

return GameControlTest
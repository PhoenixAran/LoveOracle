local Class = require 'lib.class'
local lume = require 'lib.lume'
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
  self.gameControl:setPlayer(Player('player', true, true, { x = 0, y = 0, w = 16, h = 16 }))
  local map = Map('game_control_test')
  self.gameControl:setMap(map)
  self.gameControl:setInitialRoomControlState(lume.first(map:getRooms()), 3, 3)
end

function GameControlTest:update(dt)
  self.gameControl:update(dt)
end

function GameControlTest:draw()
  self.gameControl:draw()
end

return GameControlTest
local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local GameControl = require 'engine.control.game_control'
local Map = require 'engine.tiles.map'
local BaseGameplayScreen = require 'engine.screens.base_gameplay_screen'
local Physics = require 'engine.physics'
local Player = require 'engine.player.player'
local Input = require('engine.singletons').input

---@class GameControlTest : BaseGameplayScreen
---@field gameControl GameControl
local GameControlTest = Class { __includes = BaseGameplayScreen,
  init = function(self)
    BaseGameplayScreen.init(self)
    self.gameControl = nil
    self.profiler = require 'lib.profiler'
  end
}

function GameControlTest:getType()
  return 'game_control_test'
end

return GameControlTest
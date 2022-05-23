local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local GameControl = require 'engine.control.game_control'
local Map = require 'engine.tiles.map'
local BaseScreen = require 'engine.screens.base_screen'
local Physics = require 'engine.physics'
local Player = require 'engine.player.player'
local Input = require('engine.singletons').input

-- base screen will set up the game control class for you
local BaseGameplayScreen = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.gameControl = nil
    self.profiler = require 'lib.profiler'
  end
}

function BaseGameplayScreen:getType()
  return 'base_gameplay_screen'
end

function BaseGameplayScreen:enter(prev, ...)
  self.gameControl = GameControl()

end

function BaseGameplayScreen:update()

end

return BaseGameplayScreen
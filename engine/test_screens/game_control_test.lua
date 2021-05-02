local Class = require 'lib.class'
local lume = require 'lib.lume'
local GameControl = require 'engine.control.game_control'
local BaseScreen = require 'engine.screens.base_screen'
local Physics = require 'engine.physics'


local Player = require 'engine.player.player'


local GameControlTest = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.gameControl = GameControl()
  end
}

function GameControlTest:getType()
  return 'game_control_test'
end

function GameControlTest:enter(prev, ...)

end

function GameControlTest:update(dt)

end

function GameControlTest:draw()

end

return GameControlTest
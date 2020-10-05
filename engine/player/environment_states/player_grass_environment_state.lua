local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local PlayerMotionType = require 'engine.player.player_motion_type'
local PlayerEnvironmentState = require 'engine.player.environment_states.player_environment_state'

local PlayerGrassEnvironmentState = Class { __includes = PlayerEnvironmentState,
  init = function(self)
    PlayerEnvironmentState.init(self)
    self.motionSettings.speed = 0.75
  end
}

return PlayerGrassEnvironmentState
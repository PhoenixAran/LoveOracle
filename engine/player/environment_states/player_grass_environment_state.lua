local Class = require 'lib.class'
local PlayerState = require 'data.player.player_state'
local PlayerMotionType = require 'data.player.player_motion_type'
local PlayerEnvironmentState = require 'data.player.environment_states.player_environment_state'

local PlayerGrassEnvironmentState = Class { __includes = PlayerEnvironmentState,
  init = function(self)
    PlayerEnvironmentState.init(self)
    self.motionSettings.speed = 0.75
  end
}

return PlayerGrassEnvironmentState
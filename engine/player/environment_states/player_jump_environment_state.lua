local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local PlayerMotionType = require 'engine.player.player_motion_type'
local PlayerEnvironmentState = require 'engine.player.environment_states.player_environment_state'

local PlayerJumpEnvironmentState = Class { __includes = PlayerEnvironmentState,
  init = function(self)
    PlayerEnvironmentState.init(self)
    
    self.stateParameters.
    
    self.motionSettings.speed = 1
    self.motionSettings.acceleration = 1
    self.motionSettings.deceleration = 1
  end
}

return PlayerGrassEnvironmentState
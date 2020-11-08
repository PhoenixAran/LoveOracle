local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local PlayerMotionType = require 'engine.player.player_motion_type'
local PlayerEnvironmentState = require 'engine.player.environment_states.player_environment_state'

local PlayerGrassEnvironmentState = Class { __includes = PlayerEnvironmentState,
  init = function(self)
    PlayerEnvironmentState.init(self)
    self.motionSettings.speed = 40
  end
}

function PlayerGrassEnvironmentState:getType()
  return 'player_grass_environment_state'
end

return PlayerGrassEnvironmentState
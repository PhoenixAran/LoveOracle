local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local PlayerMotionType = require 'engine.player.player_motion_type'

---@class PlayerEnvironmentState : PlayerState
---@field motionSettings PlayerMotionType
local PlayerEnvironmentState = Class { __includes = PlayerState,
  init = function(self)
    PlayerState.init(self)
    self.motionSettings = PlayerMotionType()
  end
}

function PlayerEnvironmentState:getType()
  return 'player_environment_state'
end

return PlayerEnvironmentState
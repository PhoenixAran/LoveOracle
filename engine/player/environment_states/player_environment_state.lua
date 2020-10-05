local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local PlayerMotionType = require 'engine.player.player_motion_type'

local PlayerEnvironmentState = Class { __includes = PlayerState,
  init = function(self)
    PlayerState.init(self)
    self.motionSettings = PlayerMotionType()
  end
}

return PlayerEnvironmentState
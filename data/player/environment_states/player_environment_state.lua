local Class = require 'lib.class'
local PlayerState = require 'data.player.player_state'
local PlayerMotionType = require 'data.player.player_motion_type'

local PlayerEnviromentState = Class { __includes = PlayerState,
  init = function(self)
    PlayerState.init(self)
    self.motionSettings = PlayerMotionType()
  end
}
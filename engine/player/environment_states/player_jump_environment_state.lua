local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local PlayerMotionType = require 'engine.player.player_motion_type'
local PlayerEnvironmentState = require 'engine.player.environment_states.player_environment_state'

local PlayerJumpEnvironmentState = Class { __includes = PlayerEnvironmentState,
  init = function(self)
    PlayerEnvironmentState.init(self)
    
    self.stateParameters.canStrafe = false
    self.stateParameters.canPush = false
    self.stateParameters.canLedgeJump = false
    self.stateParameters.canRoomTransition = false
    
    -- value modifiers for Movement component
    self.motionSettings.speed = 1
    self.motionSettings.acceleration = 0.033
    self.motionSettings.deceleration = 0
    self.motionSettings.minSpeed = .5 -- TODO: implement minSpeed in Movement
    
    -- used for man handling movement in player
    self.motionSettings.slippery = true
    self.motionSettings.directionSnapCount = 8
  end
}

function PlayerJumpEnvironmentState:getType()
  return 'playerjumpenvironmentstate'
end

return PlayerJumpEnvironmentState
local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local PlayerMotionType = require 'engine.player.player_motion_type'
local PlayerEnvironmentState = require 'engine.player.environment_states.player_environment_state'

---@class PlayerJumpEnvironmentState : PlayerEnvironmentState
local PlayerJumpEnvironmentState = Class { __includes = PlayerEnvironmentState,
  init = function(self)
    PlayerEnvironmentState.init(self)

    self.stateParameters.canStrafe = true
    self.stateParameters.canPush = false
    self.stateParameters.canLedgeJump = false
    self.stateParameters.canRoomTransition = false
    self.stateParameters.autoCorrectMovement = false

    -- value modifiers for Movement component
    self.motionSettings.speed = 60
    self.motionSettings.acceleration = .33
    self.motionSettings.deceleration = 0
    self.motionSettings.minSpeed = 0.05

    -- used for man handling movement in player
    self.motionSettings.slippery = true
    self.motionSettings.directionSnapCount = 8
  end
}

function PlayerJumpEnvironmentState:getType()
  return 'player_jump_environment_state'
end

return PlayerJumpEnvironmentState
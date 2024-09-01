local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'

local PlayerLedgeJumpState = Class { __includes = PlayerState,
  init = function(self)
    PlayerState.init(self)


    self.stateParameters.canAutoRoomTransition = true
    self.stateParameters.canStrafe = true

    self.stateParameters.canWarp = false
    self.stateParameters.canControlOnGround = false
    self.stateParameters.canControlInAir = false
    self.stateParameters.canUseWeapons = false
    self.stateParameters.canReleaseSword = false
    self.stateParameters.canUseWeapons = false
  end
}

function PlayerLedgeJumpState:getType()
  return 'player_ledge_jump_state'
end

function PlayerLedgeJumpState:onBegin(previousState)
  -- TODO temporarily disable solid collisions
end

function PlayerLedgeJumpState:onEnd(newState)
  -- TODO reenable collisions
end

function PlayerLedgeJumpState:onEnterRoom()
  -- TODO
end

function PlayerLedgeJumpState:update(dt)
  
end

return PlayerLedgeJumpState

local Class = require 'lib.class'

local PlayerStateParameters = Class {
  init = function(self)
    -- everything is false by default
    self.canMove = false
    self.canJump = false
    self.canWarp = false
    self.canLedgeJump = false
    self.canControlInAir = false
    self.canPush = false
    self.canUseWeapons = false
    self.canRoomTransition = false
    self.canStrafe = false
    self.alwaysFaceUp = false
    self.alwaysFaceDown = false
    self.alwaysFaceLeft = false
    self.alwaysFaceRight = false
    self.disableAnimationPauseWhenNotMoving = false
    
    self.disableMovement = false
    self.disableUpdateMethod = false
    self.movementSpeedScale = 1.0
  end
}

return PlayerStateParameters
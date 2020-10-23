local Class = require 'lib.class'

local PlayerStateParameters = Class {
  init = function(self)
    
    self.playerAnimations = { 
      swing = nil,
      swingNoLunge = nil,
      swingBig = nil,
      spin = nil,
      stab = nil,
      aim = nil,
      throw = nil,
      default = nil,
      carry = nil,
      
      count = nil
    }
    
    -- default values
    self.canJump = true
    self.canWarp = true
    self.canLedgeJump = true
    self.canControlOnGround = true
    self.canControlInAir = true
    self.canPush = true
    self.canUseWeapons = true
    self.canRoomTransition = true
    self.canStrafe = true
    self.animationPauseWhenMoving = true
    
    self.alwaysFaceUp = false
    self.alwaysFaceDown = false
    self.alwaysFaceLeft = false
    self.alwaysFaceRight = false

    
    --self.disableMovement = false
    --self.disableUpdateMethod = false
    
    self.movementSpeedScale = 1.0
  end
}



return PlayerStateParameters
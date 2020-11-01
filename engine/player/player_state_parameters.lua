local Class = require 'lib.class'

local PlayerStateParameters = Class {
  init = function(self)
    
    self.animations = { 
      swing = nil,
      swingNoLunge = nil,
      swingBig = nil,
      spin = nil,
      stab = nil,
      aim = nil,
      throw = nil,
      default = nil,
      move = nil,
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
    self.defaultAnimationWhenNotMoving = true
    
    self.alwaysFaceUp = false
    self.alwaysFaceDown = false
    self.alwaysFaceLeft = false
    self.alwaysFaceRight = false
    
    self.movementSpeedScale = 1.0
  end
}

PlayerStateParameters.EmptyStateParameters = PlayerStateParameters()

function PlayerStateParameters:getType()
  return 'playerstateparameters'
end

function PlayerStateParameters:integrateParameters(other)
  self.canJump = self.canJump or other.canJump
  self.canWarp = self.canWarp or other.canWarp
  self.canLedgeJump = self.canLedgeJump or other.canLedgeJump
  self.canControlOnGround = self.canControlOnGround or other.canControlOnGround
  self.canPush = self.canPush or other.canPush
  self.canUseWeapons = self.canUseWeapons or other.canUseWeapons
  self.canRoomTransition = self.canRoomTransition or other.canRoomTransition
  self.canStrafe = self.canStrafe or other.canStrafe
  self.defaultAnimationWhenNotMoving = self.defaultAnimationWhenNotMoving or other.defaultAnimationWhenNotMoving
  
  self.alwaysFaceUp = self.alwaysFaceUp or other.alwaysFaceUp
  self.alwaysFaceDown = self.alwaysFaceDown or other.alwaysFaceDown
  self.alwaysFaceLeft = self.alwaysFaceLeft or other.alwaysFaceLeft
  self.alwaysFaceRight = self.alwaysFaceRight or other.alwaysFaceRight
  
  -- prefer the other animations if they are non null
  for k, v in ipairs(self.animations) do
    self.animations[k] = other.animations[k] or self.animations[k]
  end  
end

function PlayerStateParameters:reset()
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
    self.defaultAnimationWhenNotMoving = true
    
    self.alwaysFaceUp = false
    self.alwaysFaceDown = false
    self.alwaysFaceLeft = false
    self.alwaysFaceRight = false
    
    self.movementSpeedScale = 1.0
    
    for k, v in pairs(self.animations) do
      self.animations[k] = nil
    end
end

if pool then
  pool.register('playerstateparameters', PlayerStateParameters)
end

return PlayerStateParameters
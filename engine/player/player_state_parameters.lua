local Class = require 'lib.class'
local Pool = require 'engine.utils.pool'

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
    self.defaultAnimationWhenNotStill = true
    
    self.canStrafe = false
    self.alwaysFaceUp = false
    self.alwaysFaceDown = false
    self.alwaysFaceLeft = false
    self.alwaysFaceRight = false
    
    self.movementSpeedScale = 1.0
  end
}

PlayerStateParameters.EmptyStateParameters = PlayerStateParameters()

function PlayerStateParameters:getType()
  return 'player_state_parameters'
end

-- helper function for integrateParameters
-- some parameters we want to prioritize false values over true
local function prioritizeFalse(a, b)
  if not a then return a end
  if not b then return b end
  return a
end

function PlayerStateParameters:integrateParameters(other)
  self.canJump = prioritizeFalse(self.canJump, other.canJump)
  self.canWarp =  prioritizeFalse(self.canWarp, other.canWarp)
  self.canLedgeJump =  prioritizeFalse(self.canLedgeJump, other.canLedgeJump)
  self.canControlOnGround =  prioritizeFalse(self.canControlOnGround, other.canControlOnGround)
  self.canPush =  prioritizeFalse(self.canPush, other.canPush)
  self.canUseWeapons =  prioritizeFalse(self.canUseWeapons, other.canUseWeapons)
  self.canRoomTransition =  prioritizeFalse(self.canRoomTransition, other.canRoomTransition)
  self.defaultAnimationWhenNotMoving =  prioritizeFalse(self.defaultAnimationWhenNotMoving, other.defaultAnimationWhenNotMoving)
  
  -- you wanna prioritize true for these ones
  self.alwaysFaceUp = self.alwaysFaceUp or other.alwaysFaceUp
  self.alwaysFaceDown = self.alwaysFaceDown or other.alwaysFaceDown
  self.alwaysFaceLeft = self.alwaysFaceLeft or other.alwaysFaceLeft
  self.alwaysFaceRight = self.alwaysFaceRight or other.alwaysFaceRight
  self.canStrafe = self.canStrafe or other.canStrafe

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
    self.defaultAnimationWhenNotMoving = true
    
    self.canStrafe = false
    self.alwaysFaceUp = false
    self.alwaysFaceDown = false
    self.alwaysFaceLeft = false
    self.alwaysFaceRight = false
    
    self.movementSpeedScale = 1.0
    
    for k, v in pairs(self.animations) do
      self.animations[k] = nil
    end
end

if Pool then
  Pool.register('player_state_parameters', PlayerStateParameters)
end

return PlayerStateParameters
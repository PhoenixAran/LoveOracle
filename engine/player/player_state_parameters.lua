local Class = require 'lib.class'
local Pool = require 'engine.utils.pool'

---@class PlayerStateParameters
---@field animations table<string, string>
---@field canJump boolean
---@field canWarp boolean
---@field canLedgeJump boolean
---@field canControlOnGround boolean
---@field canControlInAir boolean
---@field canPush boolean
---@field canUseWeapons boolean
---@field canReleaseSword boolean
---@field canRoomTransition boolean
---@field defaultAnimationWhenNotStill boolean
---@field interactionCollisions boolean
---@field hitboxCollisions boolean
---@field canAutoRoomTransition boolean
---@field canStrafe boolean
---@field alwaysFaceUp boolean
---@field alwaysFaceDown boolean
---@field alwaysFaceLeft boolean
---@field alwaysFaceRight boolean
---@field EmptyStateParameters PlayerStateParameters
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

    -- note you can still jump when these are false
    self.canControlOnGround = true
    self.canControlInAir = true

    self.canPush = true
    self.canUseWeapons = true
    -- can release a sword charge
    self.canReleaseSword = true
    self.canRoomTransition = true

    -- im not sure when this is used
    self.defaultAnimationWhenNotStill = true

    -- if the player should be moved if they snag a corner
    self.autoCorrectMovement = true

    -- params that are false by default

    -- triggers room transition no matter how player collides with a room_edge (normally, we only trigger room 
    -- transition if player is deliberately trying to move into it, and not when they get bumped by an enemy or something)
    self.canAutoRoomTransition = false
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

---@param other PlayerStateParameters
function PlayerStateParameters:integrateParameters(other)
  self.canJump = prioritizeFalse(self.canJump, other.canJump)
  self.canWarp =  prioritizeFalse(self.canWarp, other.canWarp)
  self.canLedgeJump =  prioritizeFalse(self.canLedgeJump, other.canLedgeJump)
  self.canControlOnGround =  prioritizeFalse(self.canControlOnGround, other.canControlOnGround)
  self.canPush =  prioritizeFalse(self.canPush, other.canPush)
  self.canUseWeapons =  prioritizeFalse(self.canUseWeapons, other.canUseWeapons)
  self.canReleaseSword = prioritizeFalse(self.canReleaseSword, other.canReleaseSword)
  self.canRoomTransition =  prioritizeFalse(self.canRoomTransition, other.canRoomTransition)
  self.defaultAnimationWhenNotMoving =  prioritizeFalse(self.defaultAnimationWhenNotMoving, other.defaultAnimationWhenNotMoving)
  self.autoCorrectMovement = prioritizeFalse(self.autoCorrectMovement, other.autoCorrectMovement)
  self.interactionCollisions = prioritizeFalse(self.interactionCollisions, other.interactionCollisions)
  self.hitboxCollisions = prioritizeFalse(self.hitboxCollisions, other.hitboxCollisions)

  -- you wanna prioritize true for these ones
  self.alwaysFaceUp = self.alwaysFaceUp or other.alwaysFaceUp
  self.alwaysFaceDown = self.alwaysFaceDown or other.alwaysFaceDown
  self.alwaysFaceLeft = self.alwaysFaceLeft or other.alwaysFaceLeft
  self.alwaysFaceRight = self.alwaysFaceRight or other.alwaysFaceRight
  self.canStrafe = self.canStrafe or other.canStrafe
  self.canAutoRoomTransition = self.canAutoRoomTransition or other.canAutoRoomTransition

  -- prefer the other animations if they are non null
  for k, v in pairs(self.animations) do
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
    self.autoCorrectMovement = true
    self.interactionCollisions = true

    self.canStrafe = false
    self.alwaysFaceUp = false
    self.alwaysFaceDown = false
    self.alwaysFaceLeft = false
    self.alwaysFaceRight = false
    self.canAutoRoomTransition = false

    self.movementSpeedScale = 1.0

    for k, v in pairs(self.animations) do
      self.animations[k] = nil
    end
end

if Pool then
  Pool.register('player_state_parameters', PlayerStateParameters)
end

return PlayerStateParameters
local Class = require 'lib.class'
local PlayerMotionType = require 'engine.player.player_motion_type'
local vector = require 'engine.math.vector'
local Movement = require 'engine.components.movement'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local Input = require('engine.singletons').input

-- some class constants
local JUMP_Z_VELOCITY = 2
local JUMP_GRAVITY = 8
-- how many times to 'split the pie' when clamping joystick vector to certian radian values
local DIRECTION_SNAP = 40

---@class PlayerMovementController
---@field player Player
---@field movement Movement
---@field allowMovementControl boolean
---@field strokeSpeedScale number
---@field lastStrokeVectorX number
---@field lastStrokeVectorY number
---@field directionX number
---@field directionY number
---@field stroking boolean
---@field capeDeployed boolean
---@field holeTile Tile?
---@field holeDoomTimer number
---@field holeSlipVelocityX number
---@field holeSlipVelocityY number
---@field fallingInHole boolean
---@field moveNormalMode PlayerMotionType
---@field mode PlayerMotionType
local PlayerMovementController = Class {
  ---@param self PlayerMovementController
  ---@param player Player
  ---@param movement Movement
  init = function(self, player, movement)
    self.player = player
    self.movement = movement

    self.allowMovementControl = true
    self.strokeSpeedScale = 1.0
    self.directionX, self.directionY = 0, 0
    self.moving = false
    self.stroking = false
    self.lastStrokeVectorX = 0
    self.lastStrokeVectorY = 0
    self.capeDeployed = false
    self.holeTile = nil
    self.holeDoomTimer = 0
    self.holeSlipVelocityX, self.holeSlipVelocityY = 0, 0
    self.fallingInHole = false

    self.moveNormalMode = PlayerMotionType()
    self.mode = self.moveNormalMode
  end
}

function PlayerMovementController:isMoving()
  return self.moving
end

---@param mode PlayerMotionType
function PlayerMovementController:setMode(mode)
  if self.mode ~= mode then
    self.mode = mode
    self.movement:setSpeed(mode.speed)
    self.movement:setAcceleration(mode.acceleration)
    self.movement:setDeceleration(mode.deceleration)
    self.movement:setMinSpeed(mode.minSpeed)
    self.movement:setSlippery(mode.slippery)
  end
end

function PlayerMovementController:jump()
  if self.player:isOnGround() and self.player:getStateParameters().canJump then
    if self.player:getStateParameters().canControlOnGround then
      local x, y = self:pollMovementControls(true)
      if self:isMoving() then
        self.player:setVector(x, y)
        -- man handle the speed
        self.movement:setSpeed(self.movement:getSpeed() * self.player:getStateParameters().movementSpeedScale * self.strokeSpeedScale)
      end
    end
    -- jump!
    self.capeDeployed = false
    self.movement.gravity = JUMP_GRAVITY
    self.movement:setZVelocity(JUMP_Z_VELOCITY)
    self.player:requestNaturalState()
    self.player:integrateStateParameters()
    if self.player:getWeaponState() ~= nil and self.player:getWeaponState():getType() == 'player_push_state' then
      -- end the push state so we can jump
      self.player:getWeaponState():endState()
      self.player:integrateStateParameters()
    end
    if self.player:getWeaponState() == nil then
      self.player.sprite:play('jump')
    end
    -- TODO self.player:onJump()
  end
end

---@param allowMovementControl boolean
function PlayerMovementController:pollMovementControls(allowMovementControl)
  local x, y = 0, 0
  self.moving = false
  if allowMovementControl then
    x, y = Input:get('move')
    x, y = vector.snapDirectionByCount(x, y, DIRECTION_SNAP)
    self.directionX, self.directionY = x, y
    if x ~= 0 or y ~= 0 then
      self.moving = true
    end
  end
  return x, y
end

function PlayerMovementController:chooseAnimation()
  local player = self.player
  local sprite = self.player.sprite
  local stateParameters = self.player:getStateParameters()
  local animation = sprite:getCurrentAnimationKey()
  if player:isOnGround() and self.allowMovementControl and
     (animation == player:getPlayerAnimations().move or animation == 'idle' or animation == 'carry') then

    if self.moving then
      if not sprite:isPlaying() then
        sprite:play()
      end
    elseif animation ~= player:getPlayerAnimations().default then
      sprite:play(player:getPlayerAnimations().default)
    end
  end

  -- change to the default animation while in the air and not using weapon
  if player:isInAir() and self.allowMovementControl and player:getWeaponState() == nil and sprite:getCurrentAnimationKey() ~= 'jump' then
    sprite:play(player:getPlayerAnimations().move)
  end

  animation = sprite:getCurrentAnimationKey()

  -- move animation can be replaced by cap animation
  if animation == player:getPlayerAnimations().move and player:isInAir() and self.capeDeployed then
    sprite:play('cape')
  elseif player:isOnGround() and animation == 'cape' then
    sprite:play(player:getPlayerAnimations().default)
  end
end

function PlayerMovementController:updateStroking()
  if self.player:isSwimming() then
    -- slow down movement over time from strokes
    if self.strokeSpeedScale > 1.0 then
      self.strokeSpeedScale = self.strokeSpeedScale - 0.025
    end

    -- auto accelerate during the beginning of a stroke
    self.stroking = self.strokeSpeedScale > 1.3

    if self.stroking then
      -- player still needs to move if they stroke even if they dont have a direction held down
      local x, y = self.player:getVector()
      if x == 0 and y == 0 then
        self.player:setVector(self.lastStrokeVectorX, self.lastStrokeVectorY)
      else
        self.lastStrokeVectorX, self.lastStrokeVectorY = x, y
      end
    end
  else
    self.strokeSpeedScale = 1.0
    self.stroking = false
    self.lastStrokeVectorX, self.lastStrokeVectorY = 0, 0
  end
  
  self.player:setSpeedScale(self.strokeSpeedScale)
end

--- if we can stroke in the water
---@return boolean
function PlayerMovementController:canStroke()
  return self.player:isSwimming() and self.strokeSpeedScale <= 1.4 and self.allowMovementControl
end

function PlayerMovementController:stroke()
  self.strokeSpeedScale = 2.0
  self.player:setSpeedScale(self.strokeSpeedScale)
  -- TODO play audio
  self.stroking = true

  local x, y = self.player:getVector()
  if x == 0 and y == 0 then
    self.lastStrokeVectorX, self.lastStrokeVectorY = Direction4.getVector(self.player:getAnimationDirection4())
  else
    self.lastStrokeVectorX = x
    self.lastStrokeVectorY = y
  end
end

function PlayerMovementController:updateMoveMode()
  if self.player.environmentStateMachine:isActive() then
    local currentEnvironmentState = self.player.environmentStateMachine:getCurrentState()
---@diagnostic disable-next-line: need-check-nil
    self:setMode(currentEnvironmentState.motionSettings)
  else
    self:setMode(self.moveNormalMode)
  end
end

function PlayerMovementController:updateMoveControls()
  if self.player:isInAir() then
    if not self.player:getStateParameters().canControlInAir then
      self.allowMovementControl = false
    elseif self.player.movement:getZVelocity() >= .1 then
      self.allowMovementControl = false
    else
      self.allowMovementControl = true
    end
  else
    self.allowMovementControl = not self.player:inHitstun() and not self.player:inKnockback()
                                and self.player:getStateParameters().canControlOnGround
  end
  local inputX, inputY = self:pollMovementControls(self.allowMovementControl)
  local canUpdateDirection = false
  if self.player:getStateParameters().alwaysFaceUp then
    canUpdateDirection = inputX == 0 and inputY == -1
  elseif self.player:getStateParameters().alwaysFaceLeft then
    canUpdateDirection = inputX == -1 and inputY == 0
  elseif self.player:getStateParameters().alwaysFaceRight then
    canUpdateDirection = inputX == 1 and inputY == 0
  elseif self.player:getStateParameters().alwaysFaceDown then
    canUpdateDirection = inputX == 0 and inputY == 1
  else
    canUpdateDirection = not self.player:getStateParameters().canStrafe
  end

  if canUpdateDirection and self.allowMovementControl and self.moving then
    self.player:matchAnimationDirection(inputX, inputY)
  end
  self.player:setVector(inputX, inputY)
  self:chooseAnimation()
end

function PlayerMovementController:update(dt)
  self:updateMoveMode()
  self:updateMoveControls()
  self:updateStroking()
  if self.allowMovementControl then
    if self.player:getStateParameters().alwaysFaceUp then
      if self.player.animationDirection4 ~= Direction4.up then
        self.player:setAnimationDirection4(Direction4.up)
      end
    elseif self.player:getStateParameters().alwaysFaceLeft then
      if self.player.animationDirection4 ~= Direction4.left then
        self.player:setAnimationDirection4(Direction4.left)
      end
    elseif self.player:getStateParameters().alwaysFaceRight  then
      if self.player.animationDirection4 ~= Direction4.right then
        self.player:setAnimationDirection4(Direction4.right)
      end
    elseif self.player:getStateParameters().alwaysFaceDown then
      if self.player.animationDirection4 ~= Direction4.down then
        self.player:setAnimationDirection4(Direction4.down)
      end
    end
  end
end

return PlayerMovementController
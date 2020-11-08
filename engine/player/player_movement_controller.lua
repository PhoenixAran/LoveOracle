local Class = require 'lib.class'
local PlayerMotionType = require 'engine.player.player_motion_type'
local vector = require 'lib.vector'
local Movement = require 'engine.components.movement'

local PlayerMovementController = Class {
  init = function(self, player, movement)
    self.player = player
    self.movement = movement
    
    self.allowMovementControl = true
    self.strokeSpeedScale = 1.0
    
    --self.moveAxesX, self.moveAxesY = false, false
    --self.motionX, self.motionY = 0, 0
    
    self.directionX, self.directionY = 0, 0
    self.moving = false
    self.stroking = false
    self.mode = PlayerMotionType()
    --self.moveAngle = 'south'  -- not sure if I need this
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
  if self.player:isOnGround() then
    if self.player:getStateParameters().canControlOnGround then --todo check if slippery?
      local x, y = self:pollMovementControls(true)
      if self:isMoving() then
        self.player:setVector(x, y)
        -- man handle the speed
        self.movement:setSpeed(self.movement:getSpeed() * self.player:getStateParameters().movementSpeedScale * self.strokeSpeedScale)
      end
    end
    -- jump
    self.capeDeployed = false
    -- TODO remove magic numbers
    self.movement.gravity = .125
    self.movement:setZVelocity(2)
    self.player:requestNaturalState()
    self.player:integrateStateParameters()
    if self.player:getWeaponState() == nil then
      self.player.sprite:play('jump')
    else
      self.player.sprite:play(self.player:getPlayerAnimations().default)
    end
    -- TODO self.player:onJump()
  end
end

function PlayerMovementController:pollMovementControls(allowMovementControl)
  local x, y = 0, 0
  self.moving = false
  if allowMovementControl then 
  -- check movement keys
    if input:down('up') then
      y = y - 1
    end
    if input:down('down') then
      y = y + 1
    end
    if input:down('left') then
      x = x - 1
    end
    if input:down('right') then
      x = x + 1
    end
    
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
    sprite:play('jump')
  end
  
  animation = sprite:getCurrentAnimationKey()
  
  -- move animation can be replaced by cap animation
  if animation == player:getPlayerAnimations().move and player:isInAir() and self.capeDeployed then
    sprite:play('cape')
  elseif player:isOnGround() and animation == 'cape' then
    sprite:play(player:getPlayerAnimations().default)
  end
end

function PlayerMovementController:updateMoveMode()
  if self.player.environmentStateMachine:isActive() then
    self:setMode(self.player.environmentStateMachine:getState().motionSettings)
  else
    self:setMode(self.moveNormalMode)
  end
end

function PlayerMovementController:updateMoveControls()
  if self.player:isInAir() then
    if not self.player:getStateParameters().canControlInAir then
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
    canUpdateDirection = self.player:getStateParameters().canStrafe
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

  if self.allowMovementControl  then
    if self.player:getStateParameters().alwaysFaceUp then
      if self.player.direction ~= 'up' then
        self.player:setDirection('up')
      end
    elseif self.player:getStateParameters().alwaysFaceLeft then
      if self.player.direction ~= 'left' then
        self.player:setDirection('left')
      end
    elseif self.player:getStateParameters().alwaysFaceRight  then
      if self.player.direction ~= 'right' then
        self.player:setDirection('right')
      end
    elseif self.player:getStateParameters().alwaysFaceDown then
      if self.player.direction ~= 'down' then
        self.player:setDirection('down')
      end
    end
  end

end

return PlayerMovementController
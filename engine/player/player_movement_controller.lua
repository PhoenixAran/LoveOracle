local Class = require 'lib.class'
local PlayerMotionType = require 'engine.player.player_motion_type'
local vector = require 'lib.vector'

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
    self.mode = nil
    self:setMode(self.moveNormalMode)
  end
}

function PlayerMovementController:isMoving()
  return self.moving
end

function PlayerMovementController:setMode(mode)
  if self.mode ~= mode then
    self.movement.targetSpeed = self.movement.staticSpeed * mode.speed
    self.movement.currentAcceleration = self.movement.staticAcceleration * mode.acceleration
    self.movement.currentDeceleration = self.movement.staticDeceleration * mode.deceleration
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
  local animation = sprite:getCurrentAnimationKey()
  local stateParameters = self.player:getStateParameters()
  
  -- update movement animation
  if player:isOnGround() and self.allowMovementControl and
     (animation == player:getPlayerAnimations().default or animation == 'walk'
      or animation == 'idle' or animation == 'carry') then
      
    if self.moving or stateParameters.disableAnimationPauseWhenNotMoving then
      if not sprite:isPlaying() then
        sprite:play()
      end
    else
      sprite:stop()
    end
  end
  
  -- change to the default animation while in the air and not using weapon
  if player:isInAir() and self.allowMovementControl and player:getWeaponState() == nil and 
     animation ~= player:getPlayerAnimations().default or animation ~= 'jump' then
       
    sprite:play(player:getPlayerAnimations().default)
  end
  
  -- move animation can be replaced by cap animation
  if animation == player:getPlayerAnimations().default and player:isInAir() and self.capeDeployed then
    sprite:play('cape')
  elseif player:isOnGround() and animation == 'cape' then
    sprite:play(player:getPlayerAnimations().default)
  end
end

function PlayerMovementController:updateMoveMode()
  if self.player.environmentState ~= nil then
    self:setMode(self.player.environmentState.motionType)
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
  if self.allowMovementControl then
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
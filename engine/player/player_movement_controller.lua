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
    self.mode = self.moveNormalMode
  end
}

function PlayerMovementController:isMoving()
  return self.moving
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
     (animation == player:getAnimations().default or animation == 'walk'
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
     animation ~= player:getAnimations().default or animation ~= 'jump' then
       
    sprite:play(player:getAnimations().default)
  end
  
  -- move animation can be replaced by cap animation
  if animation == player:getAnimations().default and player:isInAir() and self.capeDeployed then
    sprite:play('cape')
  elseif player:isOnGround() and animation == 'cape' then
    sprite:play(player:getAnimations().default)
  end
end

function PlayerMovementController:updateMoveMode()
  if self.player.environmentState ~= nil then
    self.mode = self.player.environentState.motionType
  else
    self.mode = self.moveNormalMode
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
  local inputX, inputY = self:pollMovementKeys(self.allowMovementControl)
  
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
  
  self:chooseAnimation()
end

function PlayerMovementController:update(dt)
  self:updateMoveMode()
end

return PlayerMovementController
local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'

local PlayerSwingState = Class { __includes = PlayerState,
  init = function(self, player)
    PlayerState.init(self, player)
    self.stateParameters.canControlOnGround = false
    self.weapon = nil
    -- default values, feel free to override in other swing states
    self.lunge = true
    self.isReswingable = true
    
    -- Used to set animation direction when swing ends incase player switches direction mid spam swings.
    -- If they do switch directions, we need to set animation direction when the state end or else
    -- they will turn around to their original direction if player swings again without moving the dpad
    self.cachedDirection = nil
  end
}

function PlayerSwingState:getType()
  return 'player_swing_state'
end

function PlayerSwingState:getPlayerSwingAnimation(lunge)
  if lunge then 
    return self.player:getPlayerAnimations().swing 
  end
  return self.player:getPlayerAnimations().swingNoLunge
end

function PlayerSwingState:swing()
  local direction = self.player:getUseDirection()
  if direction == 'none' then
    direction = self.cachedDirection or self.player:getAnimationDirection()
  end
  self.weapon:swing(direction)
  local playerAnimation = self:getPlayerSwingAnimation(self.lunge)
  self.player.sprite:play(playerAnimation, direction, true)
  self.player:setAnimationDirection(direction)
  self.cachedDirection = direction
end

function PlayerSwingState:onBegin(previousState)
  self:swing()
  self.weapon:setVisible(true)
end

function PlayerSwingState:update(dt)
  if self.isReswingable and self.weapon:isButtonPressed() then
    self:swing()
  end
  
  if self.player.sprite:isCompleted() and self.weapon.sprite:isCompleted() then
    self:endState()
  end
end

function PlayerSwingState:onEnd()
  self.isReswingable = true
  self.player:setAnimationDirection(self.cachedDirection)
  self.cachedDirection = nil
  self.weapon:setVisible(false)
end

return PlayerSwingState
local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local Direction4 = require 'engine.enums.direction4'

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
    self.cachedDirection4 = nil
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
  local direction4 = self.player:getUseDirection4()
  if direction4 == Direction4.none then
    direction4 = self.cachedDirection4 or self.player:getAnimationDirection4()
  end
  self.weapon:swing(direction4)
  local playerAnimation = self:getPlayerSwingAnimation(self.lunge)
  self.player.sprite:play(playerAnimation, direction4, true)
  self.player:setAnimationDirection4(direction4)
  self.cachedDirection4 = direction4
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
  self.player:setAnimationDirection4(self.cachedDirection4)
  self.cachedDirection4 = nil
  self.weapon:setVisible(false)
end

return PlayerSwingState
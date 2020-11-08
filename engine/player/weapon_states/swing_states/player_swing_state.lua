local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'

local PlayerSwingState = Class { __includes = PlayerState,
  init = function(self)
    PlayerState.init(self)
    self.stateParameters.canControlOnGround = false
    self.weapon = nil
    -- default values, feel free to override in other swing states
    self.lunge = true
    self.isReswingable = true
    self.weaponSwingAnimation = 'swing'
  end
}

function PlayerSwingState:getPlayerSwingAnimation(lunge)
  if lunge then 
    return self.player:getPlayerAnimations().swing 
  end
  return self.player:getPlayerAnimations().swingNoLunge
end

function PlayerSwingState:swing()
  local direction = self.player:getAnimationDirection()
  self.weapon:swing(direction)
end

function PlayerSwingState:onBegin(previousState)
  self:swing()
end

function PlayerSwingState:update(dt)
  if self.isReswingable and self.weapon:isButtonPressed() then
    self:swing()
  end
  
  if self.player.sprite:isCompleted() and self.weapon.sprite:isCompleted() then
    self:endState()
  end
end

return PlayerSwingState
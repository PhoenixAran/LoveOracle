local Class = require 'lib.class'

local PlayerMotionType = Class {
  init = function(self)
    -- movement component modifiers
    self.speed = 1.0
    self.acceleration = 1
    self.deceleration = 1
    self.minSpeed = 0
    
    -- used in player code
    self.slippery = false
    self.directionSnapCount = 32 
  end
}

function PlayerMotionType:getType()
  return 'playermotiontype'
end

return PlayerMotionType
local Class = require 'lib.class'

local PlayerMotionType = Class {
  init = function(self)
    -- movement component modifiers
    self.speed = 60
    self.acceleration = 1
    self.deceleration = 1
    self.minSpeed = 0
    self.slippery = false
    
    -- TODO?
    -- self.directionSnapCount = 32 
  end
}

function PlayerMotionType:getType()
  return 'player_motion_type'
end

return PlayerMotionType
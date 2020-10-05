local Class = require 'lib.class'

local PlayerMotionType = Class {
  init = function(self)
    self.speed = 1.0
    self.slippery = false
    self.acceleration = 0.08
    self.deceleration = 0.05
    -- kinda iffy on the two bottom variables, not sure if I need them
    -- self.minSpeed = 0.05
    -- self.directionSnapCount = 32
  end
}

return PlayerMotionType
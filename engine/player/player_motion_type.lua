local Class = require 'lib.class'

local PlayerMotionType = Class {
  init = function(self)
    self.speed = 1.0
    self.acceleration = 0.08
    self.deceleration = 0.05
  end
}

return PlayerMotionType
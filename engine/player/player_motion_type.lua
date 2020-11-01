local Class = require 'lib.class'

local PlayerMotionType = Class {
  init = function(self)
    self.speed = 1.0
    self.acceleration = 1.0
    self.deceleration = 1.0
  end
}

return PlayerMotionType
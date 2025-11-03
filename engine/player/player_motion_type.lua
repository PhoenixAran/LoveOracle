local Class = require 'lib.class'
local AngleSnap = require 'engine.enums.angle_snap'

---@class PlayerMotionType
---@field speed integer
---@field acceleration integer
---@field deceleration integer
---@field minSpeed integer
---@field slippery boolean
---@field angleSnap AngleSnap
local PlayerMotionType = Class {
  init = function(self)
    -- movement component modifiers
    self.speed = 60
    self.acceleration = 1
    self.deceleration = 1
    self.minSpeed = 0.05
    self.slippery = false
    self.angleSnap = AngleSnap.to32
  end
}

function PlayerMotionType:getType()
  return 'player_motion_type'
end

return PlayerMotionType
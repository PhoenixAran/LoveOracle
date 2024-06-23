local Class = require 'lib.class'

---@class PlayerMotionType
---@field speed integer
---@field acceleration integer
---@field deceleration integer
---@field minSpeed integer
---@field slippery boolean
---@field directionSnapCount integer
local PlayerMotionType = Class {
  init = function(self)
    -- movement component modifiers
    self.speed = 60
    self.acceleration = 1
    self.deceleration = 1
    self.minSpeed = 0.05
    self.slippery = false
    self.directionSnapCount = 32
  end
}

function PlayerMotionType:getType()
  return 'player_motion_type'
end

return PlayerMotionType
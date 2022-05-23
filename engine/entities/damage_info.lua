local Class = require 'lib.class'

---@class DamageInfo
---@field sourceX number
---@field sourceY number
---@field damage integer
---@field knockbackTime integer
---@field knockbackSpeed integer
---@field hitstunTime integer
local DamageInfo = Class {
  init = function(self)
    self.sourceX = 0
    self.sourceY = 0

    self.damage = 0
    self.knockbackTime = 0
    self.knockbackSpeed = 0
    self.hitstunTime = 0
    -- todo store sound here?
    -- self.sound = nil
  end
}

function DamageInfo:getType()
  return 'damage_info'
end

---if we should apply hitstun
---@return unknown
function DamageInfo:applyHitstun()
  return 0 < self.hitstunTime
end

---if we should apply knockback
---@return unknown
function DamageInfo:applyKnockback()
  return 0 < self.knockbackTime
end

return DamageInfo
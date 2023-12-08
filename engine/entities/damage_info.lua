local Class = require 'lib.class'

---@class DamageInfo
---@field sourceX number
---@field sourceY number
---@field damage integer
---@field knockbackTime integer
---@field knockbackSpeed integer
---@field hitstunTime integer
---@field intangibilityTime integer|nil
local DamageInfo = Class {
  init = function(self, args)
    self.sourceX = args.sourceX or 0
    self.sourceY = args.sourceY or 0

    self.damage = args.damage or 0
    self.knockbackTime = args.knockbackTime or 0
    self.knockbackSpeed = args.knoackbackSpeed or 0
    self.hitstunTime = args.hitstunTime or 0
    self.intangibilityTime = args.intangibilityTime
    -- todo store sound here?
    -- self.sound = nil
  end
}

function DamageInfo:getType()
  return 'damage_info'
end

---if we should apply hitstun
---@return boolean
function DamageInfo:applyHitstun()
  return 0 < self.hitstunTime
end

---if we should apply knockback
---@return boolean
function DamageInfo:applyKnockback()
  return 0 < self.knockbackTime
end

return DamageInfo
local Class = require 'lib.class'

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

function DamageInfo:applyHitstun()
  return 0 < self.hitstunTime
end

function DamageInfo:applyKnockback()
  return 0 < self.knockbackTime
end

return DamageInfo
local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local vector = require 'lib.vector'

local Combat = Class { __includes = Component,
  init = function(self, entity)
    Component.init(self, entity)
    
    self.currentIntangibilityTime = 0
    self.currentHitstunTime = 0
    self.currentKnockbackTime = 0
    
    self.hitstunTime = 0
    self.knockbackTime = 0
    self.intangibilityTime = 0
    self.knockbackSpeed = 0
    self.knockbackDirectionX = 0
    self.knockbackDirectionY = 0 
  end
}

function Combat:getType()
  return 'combat'
end

function Combat:update(dt)
  if self:isIntangible() then 
    self.currentIntangibilityTime = self.currentIntangibilityTime + 1
  end
  if self:inHitstun() then
    self.currentHitstunTime = self.currentHitstunTime + 1
  end
  if self:inKnockback() then
    self.currentKnockbackTime = self.currentKnockbackTime + 1
  end
end

function Combat:resetCombatVariables()
  self.hitstunTime = 0
  self.knockbackTime = 0
  self.intangibilityTime = 0
  
  self.currentIntangibilityTime = 0
  self.currentHitstunTime = 0
  self.currentKnockbackTime = 0

  self.knockbackSpeed = 0
  self.knockbackDirectionX = 0
  self.knockbackDirectionY = 0
end

function Combat:setIntangibility(value)
  self.intangibilityTime = value
  self.currentIntangibilityTime = 0
end

function Combat:setHitstun(value)
  self.currentHitstunTime = 0
  self.hitstunTime = value
end

function Combat:setKnockback(value)
  self.currentKnockbackTime = 0
  self.knockbackTime = value
end

function Combat:isIntangible()
  return self.currentKnockbackTime > 0 and self.currentIntangibilityTime < self.intangibilityTime
end

function Combat:inHitstun()
  return self.hitstunTime > 0 and self.currentHitstunTime < self.hitstunTime
end

function Combat:inKnockback()
  return self.knockbackTime > 0 and self.currentKnockbackTime < self.knockbackTime
end

function Combat:setKnockbackDirection(x, y)
  self.knockbackDirectionX = x
  self.knockbackDirectionY = y
end

function Combat:getKnockbackDirection()
  return self.knockbackDirectionX, self.knockbackDirectionY
end

function Combat:setKnockbackSpeed(speed)
  self.knockbackSpeed = speed
end

function Combat:getKnockbackSpeed()
  return self.knockbackSpeed
end

function Combat:getKnockbackVelocity(dt)
  return vector.mul(dt * self.knockbackSpeed, vector.normalize(self.knockbackDirectionX, self.knockbackDirectionY))
end

return Combat
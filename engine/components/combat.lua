local Class = require 'lib.class'
local Component = require 'engine.entities.component'

local Combat = Class { __includes = Component,
  init = function(self, entity)
    Component.init(self, entity)
    
    self.currentIntangibilityTime = 0
    self.currentHitstunTime = 0
    self.currentKnockbackTime = 0
    
    self.hitstunTime = 0
    self.knockbackTime = 0
    self.intangibilityTime = 0
    self.currentKnockbackSpeed = 0 -- should this be stored in a combat component?
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
  self.currentKnockbackSpeed = 0
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

return Combat
local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local vector = require 'engine.math.vector'

---handles updating of combat variables
---@class Combat : Component
---@field currentIntangibilityTime integer
---@field currentHitstunTime integer
---@field currentKnockbackTime integer
---@field hitstunTime integer
---@field knockbackTime integer
---@field intangibilityTime integer
---@field knockbackSpeed integer
---@field knockbackDirectionX integer
---@field knockbackDirectionY integer
local Combat = Class { __includes = Component,
  init = function(self, entity, args)
    Component.init(self, entity, args)

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

function Combat:update()
  if self:isIntangible() then
    self.currentIntangibilityTime = self.currentIntangibilityTime + 1
  else
    self.currentIntangibilityTime = 0
    self.intangibilityTime = 0
  end
  if self:inHitstun() then
    self.currentHitstunTime = self.currentHitstunTime + 1
  else
    self.currentHitstunTime = 0
    self.hitstunTime = 0
  end
  if self:inKnockback() then
    self.currentKnockbackTime = self.currentKnockbackTime + 1
  else
    self.currentKnockbackTime = 0
    self.knockbackTime = 0
    self.knockbackSpeed = 0
    self.knockbackDirectionX = 0
    self.knockbackDirectionY = 0
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

---@param value integer
function Combat:setIntangibility(value)
  self.intangibilityTime = value
  self.currentIntangibilityTime = 0
end

---@param value integer
function Combat:setHitstun(value)
  self.currentHitstunTime = 0
  self.hitstunTime = value
end

---@param value integer
function Combat:setKnockback(value)
  self.currentKnockbackTime = 0
  self.knockbackTime = value
end

---@return boolean
function Combat:isIntangible()
  return self.currentKnockbackTime > 0 and self.currentIntangibilityTime < self.intangibilityTime
end

---@return boolean
function Combat:inHitstun()
  return self.hitstunTime > 0 and self.currentHitstunTime < self.hitstunTime
end

---@return boolean
function Combat:inKnockback()
  return self.knockbackTime > 0 and self.currentKnockbackTime < self.knockbackTime
end

---sets knockback vector
---@param x number
---@param y number
function Combat:setKnockbackVector(x, y)
  self.knockbackDirectionX = x
  self.knockbackDirectionY = y
end

---gets knockback vector
---@return number knockbackDirectionX
---@return number knockbackDirectionY
function Combat:getKnockbackVector()
  return self.knockbackDirectionX, self.knockbackDirectionY
end

---sets knockback speed
---@param speed number
function Combat:setKnockbackSpeed(speed)
  self.knockbackSpeed = speed
end

function Combat:getKnockbackSpeed()
  return self.knockbackSpeed
end

---@return number knockbackVelocityX
---@return number knockbackVelocityY
function Combat:getKnockbackVelocity()
  return vector.mul(love.time.dt * self.knockbackSpeed, vector.normalize(self.knockbackDirectionX, self.knockbackDirectionY))
end

return Combat
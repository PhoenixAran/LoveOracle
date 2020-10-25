local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local vector = require 'lib.vector'

local Movement = Class { __includes = Component,
  init = function(self, enabled, values)
    if enabled == nil then enabled = true end
    Component.init(self, enabled)
    
    self.staticSpeed = 60
    self.staticAcceleration = 1
    self.staticDeceleration = 1
    
    self.targetSpeed = self.staticSpeed
    self.currentSpeed = 0
    self.currentAcceleration = self.staticAcceleration
    self.currentDeceleration = self.staticDeceleration
    
    self.vectorX = 0
    self.vectorY = 0
    
    self.externalForceX = 0
    self.externalForceY = 0
    
    self.cachedCounterVectorX = 0
    self.cachedCounterVectorY = 0
    self.cachedCounterSpeed = 0
  end
}

function Movement:getType()
  return 'movement'
end

function Movement:getVector()
  return self.vectorX, self.vectorY
end

function Movement:setVector(x, y)
  if x ~= 0 or y ~= 0 then
    self.cachedCounterVectorX = self.vectorX
    self.cachedCounterVectorY = self.vectorY
    self.cachedCounterSpeed = self.currentSpeed
  end
  self.vectorX = x
  self.vectorY = y
end

function Movement:getLinearVelocity(dt)
  local velocityX, velocityY = 0, 0
  if self.vectorX == 0 and self.vectorY == 0 then
    self.currentSpeed = self.currentSpeed - (self.targetSpeed * self.currentDeceleration)
    if self.currentSpeed < 0 then
      self.currentSpeed = 0
    end
    velocityX, velocityY = vector.mul(self.currentSpeed, vector.normalize(self.cachedCounterVectorX, self.cachedCounterVectorY))
  else
    self.currentSpeed = self.currentSpeed + (self.targetSpeed * self.currentAcceleration)
    if self.currentSpeed > self.targetSpeed then
      self.currentSpeed = self.targetSpeed
    end
    velocityX, velocityY = vector.mul(self.currentSpeed, vector.normalize(self.vectorX, self.vectorY))
    if self.cachedCounterVectorX ~= self.vectorX or self.cachedCounterVectorY ~= self.vectorY then
      self.cachedCounterSpeed = self.cachedCounterSpeed - (self.staticSpeed * self.currentDeceleration)
      if self.cachedCounterSpeed < 0 then
        self.cachedCounterSpeed = 0
      end
      velocityX, velocityY = vector.add(velocityX, velocityY, vector.mul(self.cachedCounterSpeed, vector.normalize(self.cachedCounterVectorX, self.cachedCounterVectorY)))
    end
  end
  return vector.mul(dt, velocityX, velocityY)
end

function Movement:recalculateLinearVelocity(dt, newX, newY)
  local velocityX, velocityY = 0, 0
  local oldX, oldY = self:getVector()
  if newX == oldX and newY == oldY then
    print('Warning: Trying to recalculate linear velocity with the same vector!')
  end
  if newX == 0 and oldX == 0 then
    velocityX, velocityY = vector.mul(self.currentSpeed, vector.normalize(self.cachedCounterVectorX, self.cachedCounterVectorY))
  else
    velocityX, velocityY = vector.mul(self.currentSpeed, vector.normalize(newX, newY))
    if self.cachedCounterVectorX ~= newX or self.cachedCounterVectorY ~= newY then
      velocityX, velocityY = vector.add(velocityX, velocityY, vector.mul(self.cachedCounterSpeed, vector.normalize(self.cachedCounterVectorX, self.cachedCounterVectorY)))
    end
  end
  self:setVector(newX, newY)
  return vector.mul(dt, velocityX, velocityY)
end

return Movement
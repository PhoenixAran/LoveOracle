local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local vector = require 'lib.vector'

local Movement = Class { __includes = Component,
  init = function(self, enabled, values)
    if enabled == nil then enabled = true end
    Component.init(self, enabled)
    
    self:signal('landed')
    self:signal('bounced')
    
    -- think of this as the directional gamepad for this entity
    self.vectorX, self.vectorY = 0, 0
    
    self.speed = 60
    self.minSpeed = 0
    self.acceleration = 1
    self.deceleration = 1
    
    self.slippery = false -- if true, this component will actually use acceleration and deceleration
    self.gravity = .125
    self.maxFallSpeed = 4
    self.zVelocity = 0
    
    -- useful for calculating acceleration and knowing when to stop accelerating movement
    self.motionX, self.motionY = 0, 0
  end
}

function Movement:getType()
  return 'movement'
end

function Movement:getVector()
  return self.vectorX, self.vectorY
end

function Movement:setVector(x, y)
  self.vectorX, self.vectorY = x, y
end

function Movement:getSpeed()
  return self.speed
end

function Movement:setSpeed(value)
  self.speed = value
end

function Movement:setMinSpeed(value)
  self.minSpeed = value
end

function Movement:getMinSpeed()
  return self.minSpeed
end

function Movement:getAcceleration()
  return self.acceleration
end

function Movement:setAcceleration(value)
  self.acceleration = value
end

function Movement:getDeceleration()
  return self.deceleration
end

function Movement:setDeceleration(value)
  self.deceleration = value
end

function Movement:isSlippery()
  return self.slippery
end

function Movement:setSlippery(value)
  self.slippery = value
end

function Movement:getMaxFallSpeed()
  return self.maxFallSpeed
end

function Movement:setMaxFallSpeed(value)
  self.maxFallSpeed = value
end

function Movement:getZVelocity()
  return self.zVelocity
end

function Movement:setZVelocity(value)
  self.zVelocity = value
end

function Movement:getLinearVelocity(dt)
  if self.vectorX == 0 and self.vectorY == 0 then
    if self.slippery then
      local length = vector.len(self.motionX, self.motionY)
      if length < vector.mul(dt * self.minSpeed, self.motionX, self.motionY) then
        self.motionX, self.motionY = 0, 0
      elseif self.motionX ~= 0 and self.motionY ~= 0 then
        self.motionX, self.motionY = vector.mul(self.motionX, self.motionY, vector.div(length, self.motionX, self.motionY))
      end
    else
      self.motionX, self.motionY = 0, 0
    end
  else
    if self.slippery then
      -- get velocity without acceleration
      local velocityX, velocityY = vector.mul(dt * self.speed, vector.normalize(self:getVector()))
      local maxLength = vector.len(velocityX, velocityY)
      
      -- add accelerated velocity to our cached motionX and motionY values
      self.motionX, self.motionY = vector.add(self.motionX, self.motionY, vector.mul(self.acceleration, velocityX, velocityY))
      
      -- if our motionX and motionY is too fast, just use our normal velocity
      if vector.len(self.motionX, self.motionY) > maxLength then
        self.motionX, self.motionY = velocityX, velocityY
      end
    else
      -- simple velocity calculation
      local velocityX, velocityY = vector.mul(dt * self.speed, vector.normalize(self:getVector()))
      self.motionX, self.motionY = velocityX, velocityY
    end
  end
  return self.motionX, self.motionY
end

function Movement:recalculateLinearVelocity(dt, newX, newY)
  --TODO
end

-- update z position
function Movement:update(dt)
  if self.entity:getZPosition() > 0 or self.zVelocity ~= 0 then
    self.zVelocity = self.zVelocity - self.gravity
    if self.maxFallSpeed >= 0 and self.zVelocity < -self.maxFallSpeed then
      self.zVelocity = -self.maxFallSpeed
    end
    self.entity:setZPosition(self.entity:getZPosition() + self.zVelocity)
    if self.entity:getZPosition() <= 0 then
      self:land()
    end
  else
    self.zVelocity = 0
  end
end

-- land entity on ground
function Movement:land()
  -- TODO if Movement.Bounces
  self.entity:setZPosition(0)
  self.zVelocity = 0
  self:emit('landed')
end

return Movement
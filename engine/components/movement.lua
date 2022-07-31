local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local vector = require 'lib.vector'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'

---component that manages an entity's movement
---@class Movement : Component
---@field speed number
---@field minSpeed number
---@field acceleration number
---@field deceleration number
---@field slippery boolean
---@field gravity number
---@field maxFallSpeed number
---@field vectorX number
---@field vectorY number
---@field zVelocity number
---@field motionX number
---@field motionY number
---@field prevMotionX number
---@field prevMotionY number
local Movement = Class { __includes = Component,
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
    Component.init(self, entity, args)

    self:signal('landed')
    self:signal('bounced')

    if args.speed == nil then args.speed = 60 end
    if args.minSpeed == nil then args.minSpeed = 0 end  --todo dont know if 0 is a good value
    if args.acceleration == nil then args.acceleration = 1 end
    if args.deceleration == nil then args.deceleration = 1 end
    if args.slippery == nil then args.slippery = false end
    if args.gravity == nil then args.gravity = 9.8 end
    if args.maxFallSpeed == nil then args.maxFallSpeed = 4 end

    -- declarations
    self.speed = args.speed
    self.minSpeed = args.minSpeed
    self.acceleration = args.acceleration
    self.deceleration = args.deceleration

    self.slippery = args.slippery -- if true, this component will actually use acceleration and deceleration
    self.gravity = args.gravity
    self.maxFallSpeed = args.maxFallSpeed


    -- updated values

    -- think of this as the directional gamepad for this entity
    self.vectorX, self.vectorY = 0, 0
    self.zVelocity = 0
    -- NB: Below values isnt how much the entity may actually move
    -- This is just the motion the movement component wants to carry out if nothing is in the way
    -- See MapEntity:move() function
    -- useful for calculating acceleration and knowing when to stop accelerating movement
    self.motionX, self.motionY = 0, 0
    -- useful for if you want to recalculate linear velocity
    self.prevMotionX, self.prevMotionY = 0, 0
  end
}

function Movement:getType()
  return 'movement'
end

function Movement:getVector()
  return self.vectorX, self.vectorY
end

---sets movement vector
---@param x number
---@param y number
function Movement:setVector(x, y)
  self.vectorX, self.vectorY = x, y
end

function Movement:getDirection4()
  return Direction4.getDirection(self:getVector())
end

function Movement:getDirection8()
  return Direction8.getDirection(self:getVector())
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

--- calculate linear velocity for this frame
---@param dt number
---@return number linearVelocityX
---@return number linearVelocityY
function Movement:getLinearVelocity(dt)
  self.prevMotionX = self.motionX
  self.prevMotionY = self.motionY
  if self.vectorX == 0 and self.vectorY == 0 then
    if self.slippery then
      local length = vector.len(self.motionX, self.motionY)
      local minLength = 0
      if self.minSpeed > .01 then
        minLength = self.minSpeed
      end
      if length < minLength then
        self.motionX, self.motionY = 0, 0
      else
        if self.motionX ~= 0 or self.motionY ~= 0 then
          self.motionX = self.motionX * ( (length - self.deceleration) / length)
          self.motionY = self.motionY * ( (length - self.deceleration) / length)
        else
          self.motionX = length - self.deceleration
          self.motionY = 0
        end
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

---@param dt any
---@param newX any
---@param newY any
---@return number, number
function Movement:recalculateLinearVelocity(dt, newX, newY)
  self.motionX, self.motionY = self.prevMotionX, self.prevMotionY
  self.vectorX, self.vectorY = newX, newY
  return self:getLinearVelocity(dt)
end

-- update z position
function Movement:update(dt)
  if self.entity:getZPosition() > 0 or self.zVelocity ~= 0 then
    self.zVelocity = self.zVelocity - (self.gravity * dt)
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

-- this is only here because i want entities to know they are in the air
-- the frame they jump lol
function Movement:isInAir()
  return self.entity:getZPosition() > 0 or self:getZVelocity() > 0
end

return Movement
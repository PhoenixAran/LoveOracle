local Class = require 'lib.class'
local Component = require 'engine.entities.component'
local vector = require 'engine.math.vector'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'

---component that manages an entity's movement
---@class Movement : Component
---@field speed number
---@field speedScale number
---@field minSpeed number
---@field acceleration number
---@field deceleration number
---@field slippery boolean
---@field movesWithConveyors boolean
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
    if args.speedScale == nil then args.speedScale = 1.0 end
    if args.minSpeed == nil then args.minSpeed = 0 end  --todo dont know if 0 is a good value
    if args.acceleration == nil then args.acceleration = 1 end
    if args.deceleration == nil then args.deceleration = 1 end
    if args.slippery == nil then args.slippery = false end
    if args.gravity == nil then args.gravity = 9.8 end
    if args.maxFallSpeed == nil then args.maxFallSpeed = 4 end

    if self.movesWithConveyors == nil then args.movesWithConveyors = true end
    -- declarations
    self.movesWithConveyors = args.movesWithConveyors

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

-- TODO set vector via setDirection4 and setDirection8?

--- get Direction4 value
---@return integer
function Movement:getDirection4()
  return Direction4.getDirection(self:getVector())
end

--- get direction8 value
---@return integer
function Movement:getDirection8()
  return Direction8.getDirection(self:getVector())
end

--- get speed. Note that this does not take into account the speed scale
---@return number
function Movement:getSpeed()
  return self.speed
end

---set speed
---@param value number
function Movement:setSpeed(value)
  self.speed = value
end

---get speed scale
---@return number
function Movement:getSpeedScale()
  return self.speedScale
end

---set speed scale
---@param value number
function Movement:setSpeedScale(value)
  self.speedScale = value
end

---get min speed
---@return number
function Movement:getMinSpeed()
  return self.minSpeed
end

---set min speed
---@param value number
function Movement:setMinSpeed(value)
  self.minSpeed = value
end

--- get acceleration
---@return number
function Movement:getAcceleration()
  return self.acceleration
end

---set acceleration
---@param value any
function Movement:setAcceleration(value)
  self.acceleration = value
end

---get deceleration
---@return number
function Movement:getDeceleration()
  return self.deceleration
end

---set deceleration
---@param value number
function Movement:setDeceleration(value)
  self.deceleration = value
end

---if movement should be slippery
---@return boolean
function Movement:isSlippery()
  return self.slippery
end

---toggle slippery movement
---@param value boolean
function Movement:setSlippery(value)
  self.slippery = value
end

---get max fall speed
---@return number
function Movement:getMaxFallSpeed()
  return self.maxFallSpeed
end

---set max fall speeed
---@param value number
function Movement:setMaxFallSpeed(value)
  self.maxFallSpeed = value
end

---get z velocity
---@return number
function Movement:getZVelocity()
  return self.zVelocity
end

---set z velocity
---@param value number
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
      local velocityX, velocityY = vector.mul(dt * self.speed * self.speedScale, vector.normalize(self:getVector()))
      local maxLength = vector.len(velocityX, velocityY)

      -- add accelerated velocity to our cached motionX and motionY values
      self.motionX, self.motionY = vector.add(self.motionX, self.motionY, vector.mul(self.acceleration, velocityX, velocityY))
      -- if our motionX and motionY is too fast, just use our normal velocity
      if vector.len(self.motionX, self.motionY) > maxLength then
        self.motionX, self.motionY = velocityX, velocityY
      end
    else
      -- simple velocity calculation
      local velocityX, velocityY = vector.mul(dt * self.speed * self.speedScale, vector.normalize(self:getVector()))
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

-- if entity is in air
function Movement:isInAir()
  -- check zvelocity as well incase we want to know if entity jumped this exact frame
  return self.entity:getZPosition() > 0 or self:getZVelocity() > 0
end

return Movement
local class = require 'lib.class'
local Transform = require 'lib.transform'
local Vector2 = require 'lib.vec2'
local ComponentList = require 'engine.entities.component_list'

local Entity = class {
  init = function(self, x, y, w, h, bumpWorld)
    --component list
    self.componentList = ComponentList()

    --bump box variables
    self.x, self.y = x - w / 2, y - h / 2
    self.w, self.h = w, h
    self.bumpWorld = bumpWorld

    --transform
    self.transform = Transform.new()
    self.transform:setPosition(x, y)

    --animation variables
    self.animState = "idle"
    self.animDirection = "down"

    --movement variables
    self.staticSpeed = 70.0
    self.staticAcceleration = 1.00
    self.staticDeceleration = 1.00

    self.targetSpeed = 0.0
    self.currentSpeed = 0.0
    self.currentAcceleration = 0.0
    self.currentDeceleration = 0.0
    self.vector = Vector2(0, 0)
    self.directionVector = Vector2(0, 0)

    self.externalForce = Vector2(0, 0)

    self.cachedCounterVector = Vector2(0, 0)
    self.cachedCounterSpeed = 0
  end
}

--transform passthroughs
function Entity:getLocalPosition()
  local x, y, z = self.transform:getLocalPosition()
  return x, y
end

function Entity:getPosition()
  local x, y, z = self.transform:getPosition()
  return x, y
end

function Entity:getBumpPosition()
  return self.x, self.y
end

function Entity:getType()
  return "entity"
end

function Entity:setPosition(x, y)
  self.x = x - self.w / 2
  self.y = y - self.h / 2
  self.transform:setPosition(x, y)
end

function Entity:setPositionWithBumpCoords(x, y)
  self.x = x
  self.y = y
  self.transform:setPosition(x + self.w / 2, y + self.h / 2)
end

function Entity:setLocalPosition(x, y)
  self.transform:setLocalPosition(x, y)
end

--hooks
function Entity:awake()
  assert(self.bumpWorld ~= nil, "Entity expects a bump world instance when awoken")
  self:resetMovementVariables()
  self.bumpWorld:add(self, self.x, self.y, self.w, self.h)
  self.componentList:entityAwake()
  self:onAwake()
end

function Entity:onAwake()
end

function Entity:remove()
  if self.bumpWorld then
    self.bumpWorld:remove(self)
  end
  componentList:entityRemove()
  self:onRemove()
end

function Entity:onRemove()
end
--accessors
function Entity:getAnimationKey()
  return self.animState .. self.animDirection
end

function Entity:setVector(x, y)
  if x ~= 0 or y ~= 0 then
    self.cachedCounterVector.x = self.vector.x
    self.cachedCounterVector.y = self.vector.y
  else
    self.cachedCounterSpeed = 0
  end

  self.vector.x = x
  self.vector.y = y
end

function Entity:setBumpWorld(bumpWorld)
  if self.bumpWorld then
    self.bumpWorld:remove(self)
  end
  self.bumpWorld = bumpWorld
end

function Entity:resetMovementVariables()
  self.targetSpeed = self.staticSpeed
  self.currentSpeed = 0
  self.currentDeceleration = self.staticDeceleration
  self.currentAcceleration = self.staticAcceleration
end

--bump and movement
function Entity:getLinearVelocity(dt)
  local linearVelocity = nil
  if self.vector:is_zero() then
    self.currentSpeed = self.currentSpeed - (self.targetSpeed * self.currentDeceleration)
    if self.currentSpeed < 0 then
      self.currentSpeed = 0
    end
    linearVelocity = self.cachedCounterVector:normalize() * self.currentSpeed
  else
    self.currentSpeed = self.currentSpeed + (self.targetSpeed * self.currentAcceleration)
    if self.currentSpeed > self.targetSpeed then
      self.currentSpeed = self.targetSpeed
    end
    linearVelocity = self.vector:normalize() * self.currentSpeed
    if self.cachedCounterVector ~= self.vector then
      self.cachedCounterSpeed = self.cachedCounterSpeed - (self.staticSpeed * self.currentDeceleration)
      if self.cachedCounterSpeed < 0 then
        self.cachedCounterSpeed = 0
      end
      linearVelocity = linearVelocity + (self.cachedCounterVector:normalize() * self.cachedCounterSpeed)
    end
  end
  return linearVelocity * dt
end

function Entity:move(linearVelocity)
  if linearVelocity:is_zero() then
    return 0, 0, nil, 0
  end
  local x, y = self:getBumpPosition()
  local actualX, actualY, collisions, count = self.bumpWorld:move(self, x + linearVelocity.x, y + linearVelocity.y, self.bumpFilter)
  local translatedX, translatedY = actualX - x, actualY - y
  self:setPositionWithBumpCoords(actualX, actualY)
  return translatedX, translatedY, collisions, count
end

function Entity:bumpFilter(item, other)
  if item:getType() == 'entity' or item:getType() == 'tile' then
    return 'slide'
  end
  --ignore by default
  return 'cross'
end

--components
function Entity:addComponent(newComponent)
  newComponent:setEntity(self)
  self.componentList:addComponent(newComponent)
end

function Entity:removeComponent(component)
  local indexPosition = 0
  for index, value in ipairs(self.componentList) do
    if value == component then
      indexPosition = index
      break
    end
  end
end

--gameloop API
function Entity:update(dt)
  self.componentList:update(dt)
end

function Entity:draw()
  self.componentList:draw()
end

function Entity:debugDraw()
  --love draws from the upper left corner so we use our bump coordinates
  local positionX, positionY = self:getBumpPosition()
  love.graphics.setColor(0, 0, 225 / 225, 70 / 255)
  love.graphics.rectangle("fill", positionX, positionY, self.w, self.h)
  self.componentList:debugDraw()
end

return Entity

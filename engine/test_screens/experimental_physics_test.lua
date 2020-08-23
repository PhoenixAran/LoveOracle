local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local vector = require 'lib.vector'

local PhysicsEntity = Class { __includes = Entity,
  init = function(self)
    Entity.init(self, true, true, { x = 0, y = 0, w = 16, h = 16 })
    -- avoid allocation
    self._boundsCalcTable = { }
    self:setCollidesWithLayer('1')
  end
}

function PhysicsEntity:entityAwake()
  physics.add(self)
end

function PhysicsEntity:update(dt)
  local inputX, inputY = 0, 0
  if input:down('left') then
    inputX = inputX - 1
  end
  if input:down('right') then
    inputX = inputX + 1
  end
  if input:down('up') then
    inputY = inputY - 1
  end
  if input:down('down') then
    inputY = inputY + 1
  end
  
  local posX, posY = self:getPosition()
  
  local velX = inputX * dt * 60
  local velY = inputY * dt * 60
  
  velX, velY = vector.normalize(velX, velY)
  
  self._boundsCalcTable.x = self.x + velX
  self._boundsCalcTable.y = self.y + velY
  self._boundsCalcTable.w = self.w
  self._boundsCalcTable.h = self.h
  
  local neighbors = physics.boxcastBroadphase(self, self._boundsCalcTable)
  for i, neighbor in ipairs(neighbors) do
    if self:reportsCollisionsWith(neighbor) then
      local collided, mtvX, mtvY, normX, normY = self:collidesWith(neighbor)
      if collided then
        -- hit, back off our motion
        velX = velX - mtvX
        velY = velY - mtvY
      end
    end
  end
  self:setPosition(posX + velX, posY + velY)
  physics.update(self)
end

local TestBox = Class { __includes = Entity,
  init = function(self, rect)
    Entity.init(self, true, true, rect)
    self:setPhysicsLayer('1')
  end
}

function TestBox:entityAwake()
  physics.add(self)
end

-- experiental physics test screen
local Screen = Class {
  init = function(self)
    self.testEntity = nil
    self.testBoxes = { }
  end
}

function Screen:enter(prev, ...)
  self.testEntity = PhysicsEntity()
  self.testEntity:entityAwake()
  self.testBoxes[#self.testBoxes+ 1] = TestBox({x = 24, y = 24, w = 24, h = 24})
  self.testBoxes[#self.testBoxes]:entityAwake()
end

function Screen:update(dt)
  for _, b in ipairs(self.testBoxes) do
    b:update(dt)
  end
  self.testEntity:update(dt)
end

function Screen:draw()
  for _, b in ipairs(self.testBoxes) do
    b:draw()
    b:debugDraw()
  end
  self.testEntity:draw()
  self.testEntity:debugDraw()
end

return Screen
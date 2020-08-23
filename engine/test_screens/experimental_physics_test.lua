local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'

local PhysicsEntity = Class { __includes = Entity,
  init = function(self)
    Entity.init(self)
    -- avoid allocation
    self._boundsCalcTable = { }
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


-- experiental physics test screen
local Screen = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function Screen:enter(prev, ...)
  self.testEntity = PhysicsEntity()
  self.testEntity:entityAwake()
end

function Screen:update(dt)
  self.testEntity:update(dt)
end

function Screen:draw()
  self.testEntity:draw()
end

return Screen
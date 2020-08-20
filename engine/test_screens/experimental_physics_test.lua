local Class = require 'lib.class'
local Entity = require 'lib.entities.entity'

local PhysicsEntity = Class { __includes = Entity,
  init = function(self)
    Entity.init(self)
    -- avoid allocation
    self._boundsCalcTable = { }
  end
}

function PhysicsEntity:entityAwake()
  physics.register(self)
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
end


-- experiental physics test screen
local Screen = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function Screen:update(dt)
end

function Screen:draw()
  love.graphics.print("Hello World!", 24, 24)
end

return Screen
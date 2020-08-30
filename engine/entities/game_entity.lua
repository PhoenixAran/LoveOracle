local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local Movement = require 'engine.components.movement'
local vector = require 'lib.vector'

--[[
  The GameEntity class is what most entities will derive from.
  It includes more actions out of the box than the plain Entity class, at the cost
  of including default components
]]
local GameEntity = Class { __includes = Entity,
  init = function(self, enabled, visible, rect)
    Entity.init(self, enabled, visible, rect)
    self.bumpFilter = nil
    self.movement = Movement()
    self._boundsCalcTable = { x = 0, y = 0, w = 0, h = 0 }
    -- add components
    self:add(self.movement)
  end
}

function GameEntity:getType()
  return 'gameentity'
end

function GameEntity:getCollisionTag()
  return 'gameentity'
end

-- movement component pass throughs
function GameEntity:getVector()
  return self.movement:getVector()
end

function GameEntity:setVector(x, y)
  return self.movement:setVector(x, y)
end

function GameEntity:getLinearVelocity(x, y)
  return self.movement:getLinearVelocity(x, y)
end

function GameEntity:move(dt)  
  local posX, posY = self:getPosition()
  local velX, velY = self.movement:getLinearVelocity(dt)
  
  self._boundsCalcTable.x = self.x + velX
  self._boundsCalcTable.y = self.y + velY
  self._boundsCalcTable.w = self.w
  self._boundsCalcTable.h = self.h
  
  local neighbors = physics.boxcastBroadphase(self, self._boundsCalcTable)
  for i, neighbor in ipairs(neighbors) do
    if self:reportsCollisionsWith(neighbor) then
      local collided, mtvX, mtvY, normX, normY = self:boxCast(neighbor, velX, velY)
      if collided then
        -- hit, back off our motion
        velX, velY = vector.sub(velX, velY, mtvX, mtvY)
      end
    end
  end
  self:setPosition(posX + velX, posY + velY)
  physics.update(self)
end

return GameEntity
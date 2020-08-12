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
  local velX, velY = self:getLinearVelocity(dt)
  local x, y = self:getBumpPosition()
  local goalX, goalY = x + velX, y + velY
  local actualX, actualY, collisions, count = bumpWorld:move(self, goalX, goalY, self.bumpFilter)
  local translatedX, translatedY = actualX - x, actualY - y
  self:setPositionWithBumpCoords(actualX, actualY)
  return translatedX, translatedY, collisions, count
end

return GameEntity
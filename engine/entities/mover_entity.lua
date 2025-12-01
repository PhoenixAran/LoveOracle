local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Entity = require 'engine.entities.entity'
local Physics = require 'engine.physics'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local Movement = require 'engine.components.movement'
local GroundObserver = require 'engine.components.ground_observer'

local canCollide = require('engine.entities.bump_box').canCollide
--- default filter for move function in Map_Entities in Physics module
---@param item MoverEntity
---@param other any
---@return string?
local function defaultMoveFilter(item, other)
  if canCollide(item, other) then
    if other.isTile and other:isTile() then
      if other:isTopTile() then
        if bit.band(item.collisionTiles, other.tileData.tileType) == 0 then
          return nil
        end
        return 'slide'
      end
      return nil
    end
    return 'slide'
  end
  return nil
end

local function defaultRoomEdgeCollisionBoxMoveFilter(item, other)
  if bit.band(PhysicsFlags:get('room_edge').value, other.physicsLayer) ~= 0 then
    return 'slide'
  end
  return nil
end


--- Entity with movement capabilities built-in
--- @class MoverEntity : Entity
---@field movement Movement
---@field groundObserver GroundObserver
---@field roomEdgeCollisionBox Collider
---@field _getMeetingTilesQueryRectFilter function filter for Physics:queryRect() when getting meeting tiles
---@field moveFilter function filter for move function in Physics:move()
---@field roomEdgeCollisionBoxMoveFilter function
---@field movesWithConveyors boolean
---@field movesWithPlatforms boolean
---@field collisionTiles integer
local MoverEntity = Class { __includes = Entity,
  init = function(self, args)
    -- Initialization code here
    Entity.init(self, args)
    
    -- components
    self.movement = Movement(self)
    self.groundObserver = GroundObserver(self)

    -- vars
    self.collisionTiles = 0

    -- move filters
    self.moveFilter = defaultMoveFilter
    self.roomEdgeCollisionBoxMoveFilter = defaultRoomEdgeCollisionBoxMoveFilter
  end
}

function MoverEntity:getType()
  return 'mover_entity'
end

function MoverEntity:movesWithConveyors()
  return self.movesWithConveyors
end

function MoverEntity:movesWithPlatforms()
  return self.movesWithPlatforms
end

---gets knockback velocity. Override for custom behavior in subclasses
---@return integer
---@return integer
function MoverEntity:getKnockbackVelocity()
  return 0, 0
end

-- movement component pass throughs
function MoverEntity:getVector()
  return self.movement:getVector()
end

function MoverEntity:setVector(x, y)
  return self.movement:setVector(x, y)
end

function MoverEntity:setZVelocity(zVelocity)
  self.movement:setZVelocity(zVelocity)
end

function MoverEntity:getDirection4()
  return self.movement:getDirection4()
end

function MoverEntity:getDirection8()
  return self.movement:getDirection8()
end

function MoverEntity:setVectorAwayFrom(x, y)
  local mx, my = self.movement:getVector()
  self.movement:setVector(vector.sub(mx, my, x, y))
end

function MoverEntity:getLinearVelocity()
  return self.movement:getLinearVelocity()
end

function MoverEntity:getTestLinearVelocity()
  return self.movement:getTestLinearVelocity()
end

function MoverEntity:getSpeed()
  return self.movement:getSpeed()
end

function MoverEntity:setSpeed(value)
  self.movement:setSpeed(value)
end

function MoverEntity:setSpeedScale(value)
  self.movement:setSpeedScale(value)
end

function MoverEntity:isInAir()
  if self.movement and self.movement:isEnabled() then
    return self.movement:isInAir()
  end
  return self:getZPosition() > 0
end

-- ground observer pass throughs
function MoverEntity:onConveyor()
  return self.groundObserver.onConveyor
end

function MoverEntity:onPlatform()
  return self.groundObserver.onPlatform
end

function MoverEntity:isInWater()
  return self.groundObserver.inWater
end

function MoverEntity:isInLava()
  return self.groundObserver.inLava
end

function MoverEntity:isInPuddle()
  return self.groundObserver.inPuddle
end

function MoverEntity:isInHole()
  return self.groundObserver.inHole
end

--- private method to handle movement logic
---@param collisions any[] table to store collisions that occur during movement
---@param isTest boolean? if true, will use test linear velocity from Movement component instead of getting it from the regular method. Defaults to false
---@return number tvx translation vector x
---@return number tvy translation vector y
function MoverEntity:_handleMove(collisions, isTest)
  local oldX, oldY = self:getBumpPosition()
  local posX, posY = self:getBumpPosition()
  local velX, velY = 0, 0
  if isTest then
    velX, velY = self:getTestLinearVelocity()
  else
    velX, velY = self:getLinearVelocity()
  end

  velX, velY = vector.add(velX, velY, self:getKnockbackVelocity())

  -- Movement due to environment
  if self:movesWithConveyors() and self:onConveyor() then
    velX, velY = vector.add(velX, velY, self.groundObserver.conveyorVelocityX, self.groundObserver.conveyorVelocityY)
  end
  if self:movesWithPlatforms() and self:onPlatform() then
    velX, velY = vector.add(velX, velY, self.groundObserver.movingPlatformX, self.groundObserver.movingPlatformY)
  end

  local goalX, goalY = vector.add(posX, posY, velX, velY)
  local actualX, actualY, cols = Physics:move(self, goalX, goalY, self.moveFilter)
  for _, v in ipairs(cols) do
    lume.push(collisions, v.other)
  end
  Physics.freeCollisions(cols)

  if self.roomEdgeCollisionBox then
    -- Create goal vector value for room edge collision box
    local diffX, diffY = vector.sub(self.x, self.y, self.roomEdgeCollisionBox.x, self.roomEdgeCollisionBox.y)
    local goalX2, goalY2 = vector.sub(actualX, actualY, diffX, diffY)
    local actualX2, actualY2, cols2 = Physics:move(self.roomEdgeCollisionBox, goalX2, goalY2, self.roomEdgeCollisionBoxMoveFilter)
    for _, col in ipairs(cols2) do
      local shouldAddToCollisions = true
      for _, collision in ipairs(collisions) do
        if col.other == collision then
          shouldAddToCollisions = false
          break
        end
      end
      if shouldAddToCollisions then
        lume.push(collisions, col.other)
      end
    end
    Physics.freeCollisions(cols2)
    actualX, actualY = vector.add(actualX2, actualY2, diffX, diffY)
  end
  local translationVectorX, translationVectorY = vector.sub(actualX, actualY, oldX, oldY)
  return translationVectorX, translationVectorY
end

return MoverEntity
local Pool = require 'engine.utils.pool'
local Class = require 'lib.class'
local EnemyState = require 'engine.entities.enemy.states.enemy_state'
local Singletons = require 'engine.singletons'
local Rect = require 'engine.math.rectangle'
local vector = require 'engine.math.vector'
local Physics = require 'engine.physics'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local TileTypes = TileTypeFlags.enumMap
local Consts = require 'constants'
local GRID_SIZE = Consts.GRID_SIZE
local SLIP_SPEED = Consts.ENEMY_FALL_IN_HOLE_SLIP_SPEED

---@param enemy Enemy
---@return Tile?
local function getCurrentHoleTile(enemy)
  local holeTile = nil
  for k, v in ipairs(enemy.groundObserver:getVisitedTiles()) do
    if v:getTileType() == TileTypes.Hole then
      holeTile = v
      break
    end
  end
  return holeTile
end

---@class EnemyFallInHoleState : EnemyState
---@field holeTile Tile?
---@field originalSpeed number
---@field originalCollisionTiles integer
local EnemyFallInHoleState = Class { __includes = EnemyState,
  init = function(self, enemy)
    EnemyState.init(self, enemy)
  end
}

function EnemyFallInHoleState:getType()
  return 'enemy_fall_in_hole_state'
end

function EnemyFallInHoleState:beginState()
  self.holeTile = getCurrentHoleTile(self.enemy)
  self.originalSpeed = self.enemy:getSpeed()
  self.originalCollisionTiles = self.enemy:getCollisionTiles()

  self.enemy:setCollisionTilesExplicit(0)
end

function EnemyFallInHoleState:update()
  -- return to normal if not in a hole
  if not self.enemy:isInHole() then
    self.enemy:beginNormalState()
    return
  end

  -- slip toward hole center
  local i, j = self.holeTile.tileIndexX, self.holeTile.tileIndexY
  local tx, ty = self.holeTile:getPosition()
  local holeRectX, holeRectY, holeRectW, holeRectH  =
    (i * GRID_SIZE) + (0.375 * GRID_SIZE),
    (j * GRID_SIZE) + (0.5 * GRID_SIZE),
    GRID_SIZE * 0.25,
    GRID_SIZE * .375

  local fallInHole = Rect.containsPoint(holeRectX, holeRectY, holeRectW, holeRectH, self.enemy:getPosition())
  local trajectoryX, trajectoryY = vector.sub(tx, ty, self.enemy:getPosition())
  if vector.len(trajectoryX, trajectoryY) > SLIP_SPEED * love.time.dt then
    self.enemy:setSpeed(SLIP_SPEED)
    self.enemy:setVector(vector.normalize(trajectoryX, trajectoryY))
    self.enemy:move()
  else
    fallInHole = true
    self.enemy:setVector(0, 0)
    self.enemy:setPosition(tx, ty)
    if self.enemy.registeredWithPhysics then
      Physics:update(self.enemy, self.enemy:getBumpPosition())
    end
  end

  if fallInHole then
    -- TODO spawn falling particles
    -- TODO play sound
    self.enemy:onFallInHole()
    self.enemy:destroy()
  end
end

function EnemyFallInHoleState:endState()
  self.enemy:setSpeed(self.originalSpeed)
  self.enemy:setVector(0, 0)
  self.enemy.collisionTiles = self.originalCollisionTiles

  self.holeTile = nil
  self.originalSpeed = 0
  self.originalCollisionTiles = 0
end

function EnemyFallInHoleState:free()
  EnemyState.free(self)
  self.holeTile = nil
  self.originalSpeed = 0
  self.originalCollisionTiles = 0
end

Pool.register('enemy_fall_in_hole_state', EnemyFallInHoleState)

return EnemyFallInHoleState
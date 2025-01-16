local Pool = require 'engine.utils.pool'
local Class = require 'lib.class'
local EnemyState = require 'engine.entities.enemy.enemy_state'
local Singletons = require 'engine.singletons'
local Rect = require 'engine.math.rectangle'
local vector = require 'engine.math.vector'
local Physics = require 'engine.physics'

local Consts = require 'constants'
local GRID_SIZE = Consts.GRID_SIZE
local SLIP_SPEED = Consts.ENEMY_FALL_IN_HOLE_SLIP_SPEED

---@class EnemyFallInHoleState : EnemyState
local EnemyFallInHoleState = Class { __includes = EnemyState,
  init = function(self, enemy)
    EnemyState.init(self, enemy)
  end
}

function EnemyFallInHoleState:getType()
  return 'enemy_fall_in_hole_state'
end

function EnemyFallInHoleState:update()
  -- return to normal if not in a hole
  if not self.enemy:isInHole() then
    self.enemy:beginNormalState()
    return
  end

  -- slip toward hole center
  local i, j = self.enemy:getTileIndex()
  -- get center of tile based off tile index
  local tx = i * GRID_SIZE + GRID_SIZE / 2
  local ty = j * GRID_SIZE + GRID_SIZE / 2

  local holeRectX, holeRectY, holeRectW, holeRectH = 
    (i * GRID_SIZE) + (0.375 * GRID_SIZE), 
    (j * GRID_SIZE) + (0.5 * GRID_SIZE), 
    GRID_SIZE * 0.25, 
    GRID_SIZE * .375

  local fallInHole = Rect.containsPoint(holeRectX, holeRectY, holeRectW, holeRectH, self.enemy:getPosition())
  local trajectoryX, trajectoryY = vector.sub(tx, ty, self.enemy:getPosition())
  if vector.len(trajectoryX, trajectoryY) > SLIP_SPEED * love.time.dt then
    self.enemy:setVector(vector.mul(SLIP_SPEED, vector.normalize(trajectoryX, trajectoryY)))
  else
    fallInHole = true
    self.enemy:setVector(0, 0)
    self.enemy:setPosition(tx, ty)
    if self.enemy.registeredWithPhysics then
      Physics:update(self.enemy, self.enemy:getPosition())
    end
  end
  
  if fallInHole then
    -- TODO spawn falling particles
    -- TODO play sound
    self.enemy:die()
  end
end

Pool.register('enemy_fall_in_hole_state', EnemyFallInHoleState)

return EnemyFallInHoleState
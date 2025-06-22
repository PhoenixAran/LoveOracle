local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local rect = require 'engine.math.rectangle'
local TablePool = require 'engine.utils.table_pool'
local MapEntity = require 'engine.entities.map_entity'
local Physics = require 'engine.physics'
local Collider = require 'engine.components.collider'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local CollisionTag = require 'engine.enums.collision_tag'
local EffectFactory = require 'engine.entities.effect_factory'
local Pool = require 'engine.utils.pool'

local Direction8Values = {Direction8.up, Direction8.upRight, Direction8.right, Direction8.downRight, Direction8.down, Direction8.downLeft, Direction8.left, Direction8.upLeft}
local Direction4Values = {Direction4.up, Direction4.right, Direction4.down, Direction4.left}

--- base enemy class with minimal functionality
--- can be used as a base class for more complex enemies
---@class Enemy : MapEntity
---@field enemyState EnemyState
---@field canFallInHole boolean
---@field canSwimInLava boolean
---@field canSwimInWater boolean
---@field movesInAir boolean
---@field jumpGravity number
---@field jumpZVelocity number
---@field fallInHoleEffectColor string
local Enemy = Class { __includes = MapEntity,
  ---@param self Enemy
  ---@param args table
  init = function(self, args)
    
    self.enemyState = nil

    -- jump behaviour configuration
    self.jumpGravity = args.jumpZGravity or 8
    self.jumpZVelocity = args.jumpZVelocity or 2.8

    -- environment configuration
    self.canFallInHole = args.canFallInHole or false
    self.canSwimInLava = args.canSwimInLava or false
    self.canSwimInWater = args.canSwimInWater or false
    self.movesInAir = args.movesInAir or false

    self.fallInHoleEffectColor = args.fallInHoleEffectColor or 'blue'

    -- set initial state
    self:changeState(Pool.obtain('enemy_normal_state'))

    -- set default collision tag for Enemy 
    self.collisionTag = CollisionTag.enemy
  end
}

function Enemy:getType()
  return 'enemy'
end

function Enemy:release()
  if self.enemyState then
    Pool.free(self.enemyState)
    self.enemyState = nil
  end
  Enemy.release(self)
end

---@param state EnemyState?
---@param forceUpdate boolean?
function Enemy:changeState(state, forceUpdate)
  forceUpdate = forceUpdate or false

  if state then
    state:setEnemy(self)
  end

  if self.enemyState then
    self:onStateEnd(self.enemyState)
    self.enemyState:endState()
    Pool.free(self.enemyState)
  end

  local oldState = self.enemyState
  self.enemyState = state

  if (oldState ~= self.enemyState or forceUpdate) and self.enemyState then
    self.enemyState:beginState()
    self:onStateBegin(self.enemyState)
  end
end

function Enemy:beginNormalState()
  self:changeState(Pool.obtain('enemy_normal_state'))
end

function Enemy:updateEnvironment()
  local state = nil
  if self:isInHole() and self.canFallInHole and (self.enemyState == nil or self.enemyState:getType() ~= 'enemy_fall_in_hole_state') then
    state = Pool.obtain('enemy_fall_in_hole_state')
    state:setEnemy(self)
  elseif self:isInWater() and not self.canSwimInWater and (self.enemyState == nil or self.enemyState:getType() ~= 'enemy_fall_in_water_state') then
    state = Pool.obtain('enemy_drown_state')
    state:setEnemy(self)
  elseif self:isInLava() and not self.canSwimInLava and (self.enemyState == nil or self.enemyState:getType() ~= 'enemy_fall_in_lava_state') then
    state = Pool.obtain('enemy_drown_state')
    state:setEnemy(self)
  end
  if state ~= nil and self.enemyState ~= state then
    self:changeState(state)
  end
end


---@return Direction4
function Enemy:getRandomDirection4()
  return lume.randomchoice(Direction4Values)
end

function Enemy:getRandomDirection8()
  return lume.randomchoice(Direction8Values)
end

function Enemy:getRandomVector2()
  return vector.normalize(lume.vector(love.math.random() * 2 * math.pi, 1))
end

function Enemy:canMoveInDirection(x, y)
  local canMoveInDirection = true
  local oldX, oldY = self.movement:getVector()
  self.movement:setVector(x, y)

  local goalX, goalY = self.movement:getTestLinearVelocity()
  local _, _, testCols, testLen = Physics:projectMove(self.x, self.y, self.w, self.h, goalX, goalY, self.moveFilter)
  for i = 1, testLen do
    local col = testCols[i]
    if self:isHazardTile(col.other) then
      canMoveInDirection = false
      break
    end
  end
  self.movement:setVector(oldX, oldY)
  Physics.freeCollisions(testCols)

  return canMoveInDirection
end

--- returns if the given tile entity is considered a hazard tile by this basic_enemy instance
--- @param tileEntity Tile
--- @return boolean
function Enemy:isHazardTile(tileEntity)
  if tileEntity:isHole() and self.canFallInHole then
    return true
  end
  if tileEntity:isLava() and not self.canSwimInLava then
    return true
  end
  if tileEntity:isDeepWater() and not self.canSwimInWater then
    return true
  end
  return false
end

--- Cancels out movement that would have put entity in a hazard tile
---@param xMovement number x amount of units to be moved horizontally
---@param yMovement number y amoujnt of units to be moved vertically
---@return number correctedXMovement, number correctedXMovement
function Enemy:checkHazardTileMovement(xMovement, yMovement)
  local correctedXMovement, correctedYMovement = 0, 0
  error('not implemented')
  return correctedXMovement, correctedYMovement
end

function Enemy:updateComponents()
  self.groundObserver:update()
  self.spriteFlasher:update()
  self.spriteSquisher:update()
  if self.sprite then
    self.sprite:update()
  end
  self.combat:update()
  self.hitbox:update()
  self.movement:update()
  self:updateEntityEffectSprite()
end

-- this is where custom enemy code should be implemented in child classes
function Enemy:updateAi()
end


function Enemy:update()
  self:updateComponents()
  self:updateEnvironment()
  if self.enemyState then
    self.enemyState:update()
  end
end

-- in game behavior action helper functions
function Enemy:jump()
  self.movement.gravity = self.jumpGravity
  self.movement:setZVelocity(self.jumpZVelocity)
---@diagnostic disable-next-line: undefined-field
  if self.onJump then
---@diagnostic disable-next-line: undefined-field
    self:onJump()
  end
end

function Enemy:fall()
  if self.sprite then
    self.sprite:play('fall')
    self.deathMarked = true
  end
---@diagnostic disable-next-line: undefined-field
  if self.onFall then
---@diagnostic disable-next-line: undefined-field
    self:onFall()
  end
end


-- implements basic callbacks for basic enemies
-- override these if you want more custom behavior
---@param state EnemyState
function Enemy:onStateEnd(state)
end

---@param state EnemyState
function Enemy:onStateBegin(state)
end

---@param state EnemyState
function Enemy:onStateUpdate(state)
end

function Enemy:onAwake()
  if self.roomEdgeCollisionBox then
    self.roomEdgeCollisionBox:entityAwake()
  end
  if self.hitbox then
    self.hitbox:entityAwake()
  end
end

---@param damageInfo DamageInfo
function Enemy:onHurt(damageInfo)
  -- TODO play sound
end

function Enemy:onDie()
  local x, y = vector.add(0, 0, self:getPosition())
  local effect = EffectFactory.createMonsterExplosionEffect(x, y)
  effect:initTransform()
  self:emit('spawned_entity', effect)
end

function Enemy:onFallInHole()
  local x, y = self:getPosition()
  local effect = EffectFactory.createFallingObjectEffect(x, y, self.fallInHoleEffectColor)
  effect:initTransform()
  self:emit('spawned_entity', effect)
end

return Enemy
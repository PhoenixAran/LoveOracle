local Class = require 'lib.class'
local Enemy = require 'engine.entities.enemy'
local Pool = require 'engine.utils.pool'
local Physics = require 'engine.physics'
local EffectFactory = require 'engine.entities.effect_factory'

-- require states so they register themslves in the pool
require 'engine.entities.enemy.states'
--- Class with built in behaviour for enemies.
--- This class automatically handles entities:
--- **falling in hole, lava, and/or water
--- **Stun State
---@class BasicEnemy : Enemy
---@field enemyState EnemyState
---@field fallInHoleEffectColor string
local BasicEnemy = Class { __includes = Enemy,
  init = function(self, args)
    Enemy.init(self, args)  
    -- environment configuration
    self.canFallInHole = args.canFallInHole or true
    self.canSwimInLava = args.canSwimInLava or false
    self.canSwimInWater = args.canSwimInWater or false

    self.fallInHoleEffectColor = args.fallInHoleEffectColor or 'blue'

    self.enemyState = Pool.obtain('enemy_normal_state')
    self.enemyState:setEnemy(self)
    self:changeState(self.enemyState)
  end
}

function BasicEnemy:getType()
  return 'basic_enemy'
end

function BasicEnemy:release()
  if self.enemyState then
    Pool.free(self.enemyState)
  end
  Enemy.release(self)
end

---@param state EnemyState?
---@param forceUpdate boolean?
function BasicEnemy:changeState(state, forceUpdate)
  if forceUpdate == nil then
    forceUpdate = false
  end
  if state then
    state:setEnemy(self)
  end
  self:onStateEnd(self.enemyState)
  self.enemyState:endState()
  local oldState = self.enemyState
  self.enemyState = state
  if (oldState ~= self.enemyState or forceUpdate) and state then
    if self.enemyState then
      Pool.free(self.enemyState)
    end
    self.enemyState:beginState()
    self:onStateBegin(state)
  end
end

function BasicEnemy:updateEnvironment()
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

function BasicEnemy:update()
  self:updateComponents()
  self:updateEnvironment()
  if self.enemyState then
    self.enemyState:update()
  end

end

function BasicEnemy:canMoveInDirection(x, y)
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
function BasicEnemy:isHazardTile(tileEntity)
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

function BasicEnemy:beginNormalState()
  self:changeState(Pool.obtain('enemy_normal_state'))
end

function BasicEnemy:onFallInHole()
  local x, y = self:getPosition()
  local effect = EffectFactory.createFallingObjectEffect(x, y, self.fallInHoleEffectColor)
  effect:initTransform()
  self:emit('spawned_entity', effect)
end

-- this is where custom enemy code should be implemented in child classes
function BasicEnemy:updateAi()
end

---@param state EnemyState
function BasicEnemy:onStateEnd(state)
end

---@param state EnemyState
function BasicEnemy:onStateBegin(state)
end

---@param state EnemyState
function BasicEnemy:onStateUpdate(state)
end

return BasicEnemy
local Class = require 'lib.class'
local Enemy = require 'engine.entities.enemy'
local Pool = require 'engine.utils.pool'

-- require states so they register themslves in the pool
require 'engine.entities.enemy.states'


--- Class with built in behaviour for enemies.
--- This class automatically handles entities:
--- **falling in hole, lava, and/or water
--- **Stun State
---@class BasicEnemy : Enemy
---@field enemyState EnemyState
local BasicEnemy = Class { __includes = Enemy,
  init = function(self, args)
    Enemy.init(self, args)  
    -- environment configuration
    self.canFallInHole = args.canFallInHole or true
    self.canSwimInLava = args.canSwimInLava or false
    self.canSwimInWater = args.canSwimInWater or false

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
  self.enemyState:update()
end

function BasicEnemy:beginNormalState()
  self.enemyState = nil
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
local Class = require 'lib.class'
local Enemy = require 'engine.entities.enemy'
-- require states so they register themslves in the pool
require 'engine.entities.enemy.enemy_fall_in_hole_state'

local Pool = require 'engine.utils.pool'


--- Class with built in behaviour for enemies.
--- This class automatically handles entities:
--- **falling in hole, lava, and/or water
--- **Stun State
---@class BasicEnemy : Enemy
---@field enemyState EnemyState?
local BasicEnemy = Class { __includes = Enemy,
  init = function(self, args)
    Enemy.init(self, args)

    -- inner state machine 
    self.enemyState = nil

    -- environment configuration
    self.canFallInHole = args.canFallInHole or true
    self.canSwimInLava = args.canSwimInLava or false
    self.canSwimInWater = args.canSwimInWater or false
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
  if self.enemyState then
    self:onStateEnd(state)
    self.enemyState:endState()
  end
  local oldState = self.enemyState
  if oldState then
    Pool.free(oldState)
  end
  self.enemyState = state
  if (oldState ~= self.enemyState or forceUpdate) and state then
    self.enemyState:beginState()
    self:onStateBegin(state)
  end
end

function BasicEnemy:updateEnvironment()
  local state = nil
  if self:isInHole() and self.canFallInHole and (self.enemyState == nil or self.enemyState:getType() ~= 'enemy_fall_in_hole_state') then
    state = Pool.obtain('enemy_fall_in_hole_state')
    state:setEnemy(self)
  elseif self:isInWater() and not self.canSwimInWater and (self.enemyState == nil and self.enemyState:getType() ~= 'enemy_fall_in_water_state') then
    state = Pool.obtain('enemy_drown_state')
    state:setEnemy(self)
  elseif self:isInLava() and not self.canSwimInLava and (self.enemyState == nil and self.enemyState:getType() ~= 'enemy_fall_in_lava_state') then
    state = Pool.obtain('enemy_drown_state')
    state:setEnemy(self)
  end
  if self.enemyState ~= state then
    self:changeState(state)
  end
end

function BasicEnemy:update()
  self:updateComponents()
  self:updateEnvironment()
  if self.enemyState then
    self.enemyState:update()
  else
    self:updateAi()
  end
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
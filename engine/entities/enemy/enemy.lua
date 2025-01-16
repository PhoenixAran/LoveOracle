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

local Direction8Values = {Direction8.up, Direction8.upRight, Direction8.right, Direction8.downRight, Direction8.down, Direction8.downLeft, Direction8.left, Direction8.upLeft}
local Direction4Values = {Direction4.up, Direction4.right, Direction4.down, Direction4.left}

---@class Enemy : MapEntity
---@field canFallInHole boolean
---@field canSwimInLava boolean
---@field canSwimInWater boolean
---@field jumpGravity number
---@field jumpZVelocity number
local Enemy = Class { __includes = MapEntity,
  ---@param self Enemy
  ---@param args table
  init = function(self, args)
    MapEntity.init(self, args)
    -- -- environment configuration
    -- self.canFallInHole = true
    -- self.canSwimInLava = false
    -- self.canSwimInWater = false -- note this is only for deep water

    -- jump behaviour configuration
    self.jumpGravity = args.jumpZGravity or 8
    self.jumpZVelocity = args.jumpZVelocity or 2.8
  end
}

function Enemy:getType()
  return 'enemy'
end

function Enemy:getCollisionTag()
  return 'enemy'
end

-- some helper functions for classes that inherit Enemy
function Enemy:canMoveInDirection(x, y)
  local canMove = true
  error('not implemented')
end

---@return Direction4
function Enemy:getRandomDirection4()
  return lume.randomchoice(Direction4Values)
end

function Enemy:getRandomDirection8()
  return lume.randomchoice(Direction8Values)
end

function Enemy:getRandomVector2()
  return 0, 0
  --return vector.normalize(lume.vector(love.math.random() * 2 * math.pi, 1))
end

function Enemy:updateComponents()
  self.groundObserver:update()
  self.spriteFlasher:update()
  if self.sprite then
    self.sprite:update()
  end
  self.combat:update()
  self.movement:update()
  self:updateEntityEffectSprite()
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

-- implements basic callbacks for basic enemies
-- override these if you want more custom behavior
function Enemy:onAwake()
  if self.roomEdgeCollisionBox then
    self.roomEdgeCollisionBox:entityAwake()
  end
end

---@param damageInfo DamageInfo
function Enemy:onHurt(damageInfo)
  -- TODO play sound
end

function Enemy:onDeath()
  -- TODO spawn sprite death effect
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

return Enemy
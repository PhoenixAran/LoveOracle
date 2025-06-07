local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local BasicEnemy = require 'engine.entities.enemy.basic_enemy'
local Direction4 = require 'engine.enums.direction4'
local SpriteBank = require 'engine.banks.sprite_bank'
local Collider = require 'engine.components.collider'
local bit = require 'bit'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local CollisionTag = require 'engine.enums.collision_tag'
local Interactions = require 'engine.entities.interactions'
local EffectFactory = require 'engine.entities.effect_factory'

local MOVING = 1
local HURT = 2
local JUMP = 3
local MARKED_DEAD = 4

-- TODO color variants

---@class Stalfos : BasicEnemy
---@field collidesWithTileNormalState string[]
---@field collidesWithTileHurtState string[]
local Stalfos = Class { __includes = BasicEnemy,
  ---@param self Stalfos
  ---@param args table
  init = function(self, args)
    if args == nil then
      args = { }
    end
    args.w, args.h = 10, 10
    args.direction = args.direction or Direction4.down
    args.sprite = SpriteBank.build('stalfos', self)
    args.roomEdgeCollisionBox = Collider(self, {
      x = -12 / 2,
      y = -13 / 2,
      w = 12,
      h = 16,
      offsetX = 0,
      offsetY = 0
    })
    args.useBumpCoords = false
    args.roomEdgeCollisionBox:setCollidesWithLayer('room_edge')
    args.fallInHoleEffectColor = 'orange'
    BasicEnemy.init(self, args)
    self:setCollidesWithLayer({'tile', 'ledge_jump'})

    self.collidesWithTileNormalState = { 'wall', 'water', 'lava', 'whirlpool', 'hole' }
    self.collidesWithTileHurtState = { 'wall'}
    self:setCollisionTiles(self.collidesWithTileNormalState)

    self.spriteFlasher:addSprite(self.sprite)
    self.spriteSquisher:addSpriteRenderer(self.sprite)
    self.movement:setSpeed(40)
    self.movement:setVector(self:getRandomVector2())
    self.hitbox:resize(12, 11)
    self.hitbox:setCollisionTag(CollisionTag.enemy)
    self.hitbox.damageInfo.damage = 2
    self.hitbox.damageInfo.knockbackSpeed = 80
    self.hitbox.damageInfo.knockbackTime = 8
    self.hitbox.damageInfo.hitstunTime = 8
    self.health:setMaxHealth(2, true)

    self.state = MOVING
    self.moveTimer = 0
    self.changeDirectionTimer = 0
    self.currentJumpDelay = 70
    self.currentDirectionDelay = 30

    self.shadowOffsetY = 6
    self.rippleOffsetY = 6

    -- set collision reactions
    self.collisionTag = CollisionTag.enemy
    self:setInteraction(CollisionTag.player, Interactions.damageOther)
    self:setInteraction(CollisionTag.sword, Interactions.takeDamage)
  end
}

function Stalfos:getType()
  return 'stalfos'
end

function Stalfos:prepForMoveState()
  self:resetCombatVariables()
  self:setVector(self:getRandomVector2())
  self.moveTimer = 0
  self.changeDirectionTimer = 0
  self.currentJumpDelay = math.floor(love.math.random(70, 121))
  self.currentDirectionDelay = math.floor(love.math.random(30, 71))
  self:setCollisionTilesExplicit(0)
  self:setCollisionTiles(self.collidesWithTileNormalState)
end

function Stalfos:land()
  self:prepForMoveState()
  -- if we were above a hole before setting it to the normal staet
  -- dont treat holes as a wall and let the stalfos fall
  if self:isInHole() then
    self:unsetCollisionTile('hole')
  end
  self.spriteSquisher:wiggle(0.10, 0.08)
  self.state = MOVING
end

function Stalfos:updateAi()
  if self.state == MOVING then
    self.moveTimer = self.moveTimer + 1
    self.changeDirectionTimer = self.changeDirectionTimer + 1
    if self.moveTimer > self.currentJumpDelay then
      self:jump()
    else
      local shouldChangeDirection = false
      shouldChangeDirection = self.changeDirectionTimer > self.currentDirectionDelay
      self.sprite:play('move')
      self:move()

      local collidedWithWall = false
      for _, collision in ipairs(self.moveCollisions) do
        if collision.isTile and collision:isTile() then
          collidedWithWall = true
        end
      end
      shouldChangeDirection = shouldChangeDirection or collidedWithWall
      if shouldChangeDirection then
        self:setVector(self:getRandomVector2())
        self.changeDirectionTimer = 0
        self.currentDirectionDelay = math.floor(love.math.random(70, 121))
      end
    end
  elseif self.state == JUMP then
    if self:isOnGround() then
      self:land()
    end
    self:move()
  elseif self.state == HURT then
    if not self.combat:inKnockback() then
      self:prepForMoveState()
      self:changeAiState(MOVING)
    end
    self:move()
  elseif self.state == MARKED_DEAD then
    self:move()
    if not self.combat:inHitstun() then
      self:die()
    end
  end
end

function Stalfos:changeAiState(state)
  self.state = state
end

-- callbacks
function Stalfos:onJump()
  self:setVector(0, 0)
  self.state = JUMP
  self.sprite:play('jump')
end

function Stalfos:onHealthDepleted()
  -- if it died its probably getting hit
  -- so set its collision to the hurt state
  self:changeAiState(MARKED_DEAD)
end

function Stalfos:onDie()
  local x, y = self:getPosition()
  local effect = EffectFactory.createMonsterExplosionEffect(x, y)
  effect:initTransform()
  self:emit('spawned_entity', effect)
end

function Stalfos:onHurt(damageInfo)
  if self.state ~= HURT or self.state ~= MARKED_DEAD then
    self:setCollisionTilesExplicit(0)
    self:setCollisionTiles(self.collidesWithTileHurtState)
  end
  if self.state ~= HURT and not self.deathMarked and not self:isIntangible() then
    self:changeAiState(HURT)
    self.moveTimer = 0
    self.changeDirectionTimer = 0
  end
end

return Stalfos


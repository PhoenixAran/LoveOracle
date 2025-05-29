local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local BasicEnemy = require 'engine.entities.enemy.basic_enemy'
local Direction4 = require 'engine.enums.direction4'
local SpriteBank = require 'engine.banks.sprite_bank'
local Collider = require 'engine.components.collider'
local bit = require 'bit'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'

local MOVING = 1
local HURT = 2
local JUMP = 3
local MARKED_DEAD = 4

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
    args.w, args.h = 8, 9
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

    self.state = MOVING
    self.moveTimer = 0
    self.changeDirectionTimer = 0
    self.currentJumpDelay = 70
    self.currentDirectionDelay = 30

    self.shadowOffsetY = 6
    self.rippleOffsetY = 6
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
  self.spriteSquisher:wiggle(0.12, 0.20)
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
  elseif self.state == HURT then
    if not self.combat:inHitstun() then
      self:prepForMoveState()
      self.state = MOVING
    end
  elseif self.state == MARKED_DEAD then
    if not self.combat:inHitstun() then
      self:destroy()
    end
  end
end

-- callbacks
function Stalfos:onJump()
  self.state = JUMP
  self.sprite:play('jump')
end

function Stalfos:onHealthDepleted()
  self.state = MARKED_DEAD
end

function Stalfos:onHurt(damageInfo)
  if self.state ~= HURT then
    self:setCollisionTilesExplicit(0)
    self:setCollisionTiles(self.collidesWithTileHurtState)
    self.state = HURT
    self.moveTimer = 0
    self.changeDirectionTimer = 0
  end
end

function Stalfos:draw()
  BasicEnemy.draw(self)
end

return Stalfos


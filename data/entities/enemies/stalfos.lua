local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local AngleSnap = require 'engine.enums.angle_snap'
local BasicEnemy = require 'engine.entities.enemy.basic_enemy'
local CollisionTag = require 'engine.enums.collision_tag'
local Interactions = require 'engine.entities.interactions'
local EffectFactory = require 'engine.entities.effect_factory'
local Collider = require 'engine.components.collider'
local SpriteBank = require 'engine.banks.sprite_bank'
local Direction4 = require 'engine.enums.direction4'
local Singletons = require 'engine.singletons'
local Input = Singletons.input

-- TODO color variants

-- consts
local STALFOS_JUMP_RANGE = 48
local STALFOS_JUMP_SPEED = 2.25
local STALFOS_JUMP_MOVE_SPEED = 60
local STALFOS_MOVE_SPEED = 30

---@class Stalfos : BasicEnemy
---@field jumpDelayTimer integer
local Stalfos = Class { __includes = BasicEnemy,
  ---@param self Stalfos
  ---@param args table
  init = function(self, args)
    -- BumpBox and sprite setup
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

    -- components
    self.health:setMaxHealth(1, true)
    self.spriteFlasher:addSprite(self.sprite)
    self.spriteSquisher:addSpriteRenderer(self.sprite)

    -- movement (see basic_enemy.lua and enemy.lua)
    self.jumpZVelocity = STALFOS_JUMP_SPEED
    self.moveSpeed = STALFOS_MOVE_SPEED
    self.facePlayerOdds = 0
    self.changeDirectionOnCollision = true
    self.movesInAir = false
    self.stopTimeMin = 0
    self.stopTimeMax = 0
    self.moveTimeMin = 30
    self.moveTimeMax = 80
    self.avoidHazardTilesInAir = true
    self:setAngleSnap(AngleSnap.to16)
    

    -- physics
    self:setCollidesWithLayer({'tile', 'ledge_jump'})
    self:setCollisionTiles({'wall'})

    -- hitbox
    self.hitbox:resize(12, 11)
    self.hitbox:setCollisionTag(CollisionTag.enemy)
    self.hitbox.damageInfo.damage = 2
    self.hitbox.damageInfo.knockbackSpeed = 80
    self.hitbox.damageInfo.knockbackTime = 8
    self.hitbox.damageInfo.hitstunTime = 8

    -- set collision reactions
    self.collisionTag = CollisionTag.enemy
    self:setInteraction(CollisionTag.player, Interactions.damageOther)
    self:setInteraction(CollisionTag.sword, Interactions.takeDamage)

    -- BasicEnemy setup
    self.isMoving = true
    self.sprite:play(self.animationMove)

    -- stalfos
    self.jumpDelayTimer = 0

    self.movement:connect('landed', self, 'onLand')
  end
}

function Stalfos:getType()
  return 'stalfos'
end

function Stalfos:onAwake()
  BasicEnemy.onAwake(self)
  local roomControl = Singletons.roomControl
  local player = nil
  if roomControl then
    player = roomControl:getPlayer()
  end
  if player then
    player:connect('entity_item_used', self, "_onPlayerItemUsed")
  end
end

function Stalfos:updateAi()
  BasicEnemy.updateAi(self)
  if self.jumpDelayTimer > 0 then
    self.jumpDelayTimer = self.jumpDelayTimer - 1
  end
end

---@param player Player
function Stalfos:jumpAwayFromPlayer(player)
  self:setZVelocity(STALFOS_JUMP_SPEED)
  self:setSpeed(STALFOS_JUMP_MOVE_SPEED)

  local x, y = self:getPosition()
  local px, py = player:getPosition()
  local vectorX, vectorY = vector.normalize(vector.sub(x, y, px, py))
  self:setVector(vectorX, vectorY)
  self:jump()
end

function Stalfos:onJump()
  BasicEnemy.onJump(self)
  self.sprite:play('jump')
end

function Stalfos:onLand()
  BasicEnemy.onLand(self)
  self.sprite:play(self.animationMove)
end

function Stalfos:_onPlayerItemUsed()
  -- check for jumnping toward or away fro mthe player
  if self:isOnGround() and self.jumpDelayTimer == 0 then
    -- get player
    local player = Singletons.roomControl:getPlayer()
    if player then
      local x, y = self:getPosition()
      local px, py = player:getPosition()
      local distanceToPlayer = vector.dist(x, y, px, py)
      if distanceToPlayer <= STALFOS_JUMP_RANGE then
        self:jumpAwayFromPlayer(player)
      end
    end
  end
end

function Stalfos:draw()
  BasicEnemy.draw(self)
end

function Stalfos:onHurt(damageInfo)
  if not self:isIntangible() then
    if damageInfo.hitstunTime > 0 then
      self:pause(damageInfo.hitstunTime)
    end
  end
end

return Stalfos
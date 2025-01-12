local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Enemy = require 'engine.entities.enemy'
local Direction4 = require 'engine.enums.direction4'
local SpriteBank = require 'engine.banks.sprite_bank'
local Collider = require 'engine.components.collider'
local Hitbox = require 'engine.components.hitbox'


local MOVING = 1
local HURT = 2
local JUMP = 3
local MARKED_DEAD = 4

---@class Stalfos : Enemy
local Stalfos = Class { __includes = Enemy,
  init = function(self, args)
    if args == nil then
      args = { }
    end
    args.w, args.h = 8, 9
    args.direction = args.direction or Direction4.down
    Enemy.init(self, args)
    self.sprite = SpriteBank.build('stalfos', self)
    self.spriteFlasher:addSprite(self.sprite)
    self.roomEdgeCollisionBox = Collider(self, {
      x = -12 / 2,
      y = -13 / 2,
      w = 12,
      h = 16,
      offsetX = 0,
      offsetY = 0,
      detectOnly = true
    })
    self.roomEdgeCollisionBox:setCollidesWithLayer('room_edge')
    self:setCollidesWithLayer('tile')
    self:setCollisionTile({'wall'})

    self.state = MOVING
    self.moveDirection4 = Direction4.down
    self.moveTimer = 0


    self.health:connect('health_depleted', self, 'onHealthDepleted')
  end
}

function Stalfos:getType()
  return 'stalfos'
end

function Stalfos:prepForMoveState()
  self:resetCombatVariables()
  self:setVector(0, 0)
  self.moveDirection4 = self:getRandomDirection4()
end

function Stalfos:jump()
  Enemy.jump(self)
  self.sprite:play('jump')
  self.state = JUMP
  self.moveTimer = 0
end

function Stalfos:land()
  self:prepForMoveState()
  self.state = MOVING
end

function Stalfos:update()
  self:updateEntityEffectSprite()
  self.spriteFlasher:update()
  self.sprite:update()
  self.combat:update()
  self.movement:update()

  if self.state == MOVING then
    self.moveTimer = self.moveTimer + 1
    if self.moveTimer > 60 then
      self:jump()
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
      self:die()
    end
  end
end

---callback for MapEntity:hurt()
---@param damageInfo DamageInfo
function Stalfos:onHurt(damageInfo)
  -- TODO play sound
end

function Stalfos:onDeath()
  -- TODO spawn sprite death effect
end

function Stalfos:onHealthDepleted()
  self.state = MARKED_DEAD
end

return Stalfos


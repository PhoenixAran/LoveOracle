local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local BasicEnemy = require 'engine.entities.enemy.basic_enemy'
local CollisionTag = require 'engine.enums.collision_tag'
local Interactions = require 'engine.entities.interactions'
local EffectFactory = require 'engine.entities.effect_factory'
local Collider = require 'engine.components.collider'
local SpriteBank = require 'engine.banks.sprite_bank'
local Direction4 = require 'engine.enums.direction4'

-- TODO color variants

---@class Stalfos : BasicEnemy
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

    -- general
    self.health:setMaxHealth(1, true)
    self.spriteFlasher:addSprite(self.sprite)
    self.spriteSquisher:addSpriteRenderer(self.sprite)

    -- movement (see basic_enemy.lua)
    self.movement:setSpeed(30)
    self.numMoveAngles = 16
    self.facePlayerOdds = 0
    self.changeDirectionOnCollision = true
    self.movesInAir = false
    self.stopTimeMin = 0
    self.stopTimeMax = 0
    self.moveTimeMin = 30
    self.moveTimeMax = 80

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

    self.isMoving = true
    self.sprite:play(self.animationMove)
  end
}

function Stalfos:getType()
  return 'stalfos'
end

function Stalfos:updateAi()
  BasicEnemy.updateAi(self)
  -- TODO jumping stuff based off player input
end

return Stalfos
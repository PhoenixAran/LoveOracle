local Class = require 'lib.class'
local Projectile require 'engine.entities.projectile.projectile'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Interactions = require 'engine.entities.interactions'
local CollisionTag = require 'engine.enums.collision_tag'
local ProjectileType = require 'engine.enums.projectile_type'
local SpriteBank = require 'engine.banks.sprite_bank'

---@class Arrow : Projectile
local Arrow = Class { __includes = Projectile,
  ---@param self Arrow
  ---@param args table
  init = function(self, args)
    -- Initialization code here
    Projectile.init(self, args)

    -- entity setup
    self.projectileType = ProjectileType.physical
    self.crashAnimation = 'crash'
    self.sprite = SpriteBank.build('projectile_monster_arrow')
    self:setCollidesWithLayer({'tile'})
    self:setCollisionTiles({'wall'})


    self.hitbox:resize(12, 11)
    self.hitbox:setCollisionTag(CollisionTag.arrow)
    self.hitbox.damageInfo.damage = 1
    self.hitbox.damageInfo.knockbackSpeed = 80
    self.hitbox.damageInfo.knockbackTime = 8
    self.hitbox.damageInfo.hitstunTime = 16

    self.interactionResolver:setInteraction(CollisionTag.player, Interactions.damageOther)
    self.interactionResolver:setInteraction(CollisionTag.sword, Interactions.deflect)
    self.interactionResolver:setInteraction(CollisionTag.shield, Interactions.deflect)
    self.interactionResolver:setInteraction(CollisionTag.arrow, Interactions.deflect)
  end
}

function Arrow:getType()
  return 'arrow'
end

function Arrow:onAwake()
  Projectile.onAwake(self)
  self.sprite:play('move')
end

function Arrow:onCrash()
  Projectile.onCrash(self)
  -- TODO play cling sound
end

return Arrow                                                    
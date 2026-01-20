local Projectile = require 'engine.entities.projectile.projectile'
local Class = require 'lib.class'
local SpriteBank = require 'engine.banks.sprite_bank'
local ProjectileType = require 'engine.enums.projectile_type'
local CollisionTag = require 'engine.enums.collision_tag'
local AnimationDirectionSyncMode = require 'engine.enums.animation_direction_sync_mode'

---@class BoneProjectile : Projectile
local BoneProjectile = Class { __includes = Projectile,
  ---@param self BoneProjectile
  ---@param args table
  init = function(self, args)
    Projectile.init(self, args)

    -- entity setup
    self.collisionTag = CollisionTag.thrownProjectile
    self.projectileType = ProjectileType.physical
    self.crashAnimation = 'effect_rock_break'
    self.sprite = SpriteBank.build('projectile_monster_bone', self)
    self.animDirectionSyncMode = AnimationDirectionSyncMode.none
    self:setCollidesWithLayer({'tile'})
    self:setCollisionTiles('wall')

    self.hitbox:resize(10, 10)
    self.hitbox:setCollisionTag(self.collisionTag)
    self.hitbox.damageInfo.damage = 2
    self.hitbox.damageInfo.knockbackSpeed = 80
    self.hitbox.damageInfo.knockbackTime = 8
    self.hitbox.damageInfo.hitstunTime = 8
  end
}


function BoneProjectile:getType()
  return 'bone_projectile'
end

function BoneProjectile:onAwake()
  Projectile.onAwake(self)
  self.sprite:play('move')
end

return BoneProjectile


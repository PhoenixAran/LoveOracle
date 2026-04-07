local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Boomerang = require 'engine.entities.projectile.boomerang'
local CollisionTag = require 'engine.enums.collision_tag'
local Interactions = require 'engine.entities.interactions'
local SpriteBank = require 'engine.banks.sprite_bank'

local BOOMERANG_BASE_SPEED = 90


-- TODO implement collectible collecting when collectibles are implemented

---@class PlayerBoomerang : Boomerang
---@field collectibles any[]
local PlayerBoomerang = Class { __includes = Boomerang,
  ---@param self PlayerBoomerang
  ---@param args table
  init = function(self, args)
    args.w = 2
    args.h = 2
    Boomerang.init(self, args)
    local itemBoomerang = args.itemBoomerang
    if itemBoomerang == nil then
      error('itemBoomerang argument is required to create a PlayerBoomerang')
    end

    self:setCollidesWithLayer({'tile'})
    self:setCollisionTiles('wall')

    self.sprite = SpriteBank.build('player_boomerang_' .. itemBoomerang:getLevel(), self)
    self.hitbox:setCollisionTag(CollisionTag.boomerang)
    self.hitbox:setPhysicsLayer('hitbox_player')
    self.hitbox:setCollidesWithLayer('hitbox_enemy')
    self.hitbox.damageInfo.damage = itemBoomerang:getLevel()
    self.hitbox.damageInfo.hitstunTime = 90
    self.hitbox.damageInfo.knockbackSpeed = 0
    self.hitbox.damageInfo.knockbackTime = 0
    self.hitbox.damageInfo.intangibilityTime = 4
    self.hitbox.damageInfo.flashSprite = false



    self:setSpeed(BOOMERANG_BASE_SPEED * itemBoomerang:getLevel())
    self.returnDelay = 40
  end
}

function PlayerBoomerang:getType()
  return 'player_boomerang'
end

function PlayerBoomerang:onAwake()
  Boomerang.onAwake(self)
  self.sprite:play('move')
end

function PlayerBoomerang:onReturnedToOwner()
end

function PlayerBoomerang:update()
  Boomerang.update(self)
end

return PlayerBoomerang
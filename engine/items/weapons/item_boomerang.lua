local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local ItemWeapon = require 'engine.items.item_weapon'
local CollisionTag = require 'engine.enums.collision_tag'
local Direction4 = require 'engine.enums.direction4'
local EntityDebugDrawFlags = require('engine.enums.flags.entity_debug_draw_flags').enumMap
local EntityTracker = require 'engine.entities.entity_tracker'
local PlayerBoomerang = require 'engine.entities.projectile.player_projectiles.player_boomerang'
local AngleSnap = require 'engine.enums.angle_snap'
local SpriteBank = require 'engine.banks.sprite_bank'

---@class ItemBoomerang : ItemWeapon
---@field boomerangTracker EntityTracker
local ItemBoomerang = Class { __includes = ItemWeapon,
  ---@param self ItemBoomerang
  ---@param itemData ItemData
  ---@param args table
  init = function(self, itemData, args)
    ItemWeapon.init(self, itemData, args)

    self.useParameters.usableWhileJumping = true
    self.useParameters.usableWithSword = true
    self.useParameters.usableWhileInHole = true

    self.boomerangTracker = EntityTracker(1)

    -- self.item.maxLevel = 2
    -- self.item:setMenuSprite(1, SpriteBank.getSprite('icon_boomerang_1'))
    -- self.item:setMenuSprite(2, SpriteBank.getSprite('icon_boomerang_2'))
  end
}

function ItemBoomerang:getType()
  return 'item_boomerang'
end

function ItemBoomerang:onButtonPressed()
  if self.boomerangTracker:isMaxedOut() then
    return false
  end

  -- shoot and track the boomerang
  local boomerang = PlayerBoomerang({name = 'player_boomerang_projectile', itemBoomerang = self})
  local player = self:getPlayer()
  local px, py = player:getPosition()
  local useDirectionX, useDirectionY = player:getUseDirection()
  if useDirectionX == 0 and useDirectionY == 0 then
    useDirectionX, useDirectionY = Direction4.getVector(player:getAnimationDirection4())
  end
  boomerang:setPosition(px, py)
  useDirectionX, useDirectionY = AngleSnap.toVector(AngleSnap.to8, useDirectionX, useDirectionY)
  player:shootFromDirection(boomerang, useDirectionX, useDirectionY)
  boomerang:initTransform()
  self.boomerangTracker:addEntity(boomerang)
  -- use the player to emit the entity spawned signal so the Entities collection can add it
  self.player:emit('entity_spawned', boomerang)
  if self:getLevel() == 1 then
    player:beginBusyState(10, 'throw')
  else
    -- TODO magical boomerang state
  end

  return true
end

return ItemBoomerang
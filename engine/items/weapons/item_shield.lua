local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local ItemWeapon = require 'engine.items.item_weapon'
local CollisionTag = require 'engine.enums.collision_tag'
local Hitbox = require 'engine.components.hitbox'
local Direction4 = require 'engine.enums.direction4'
local EntityDebugDrawFlags = require('engine.enums.flags.entity_debug_draw_flags').enumMap
local isColliding = require('engine.entities.bump_box').isColliding
local Interactions = require 'engine.entities.interactions'
local SpriteBank = require 'engine.banks.sprite_bank'

local SHIELD_HITBOX_PLACEMENTS = {
  [Direction4.up] = {
    offsetX = 3.5,
    offsetY = -3.5,
    w = 9, 
    h = 11
  },
  [Direction4.down] = {
    offsetX = -3.5,
    offsetY = 3.5,
    w = 9, 
    h = 9
  },
  [Direction4.left] = {
    offsetX = -8,
    offsetY = 0,
    w = 2, 
    h = 14
  },
  [Direction4.right] = {
    offsetX = 6,
    offsetY = 0,
    w = 2, 
    h = 14
  }
}

---@class ItemShield : ItemWeapon
---@field hitbox Hitbox
local ItemShield = Class { __includes = ItemWeapon,
  ---@param self ItemShield
  ---@param itemData ItemData
  ---@param args table
  init = function(self, itemData, args)
    ItemWeapon.init(self, itemData, args)
    self.hitbox = Hitbox(self)
    self.hitbox:setCollisionTag(CollisionTag.shield)
    self.hitbox:setPhysicsLayer('hitbox_player')
    self.hitbox:setCollidesWithLayer('hitbox_enemy')
    self.hitbox:setEnabled(false)
    self.hitbox.damageInfo.damage = 0
    self.hitbox.damageInfo.hitstunTime = 11
    self.hitbox.damageInfo.knockbackSpeed = 75
    self.hitbox.damageInfo.intangibilityTime = 8
    self.hitbox.damageInfo.knockbackTime = 11


    self.useParameters.usableWhileJumping = true
    self.useParameters.usableWithSword = true
    self.useParameters.usableWhileInHole = true

    -- self.item.maxLevel = 3
    -- self.item:setMenuSprite(1, SpriteBank.getSprite('icon_shield_1'))
    -- self.item:setMenuSprite(2, SpriteBank.getSprite('icon_shield_2'))
    -- self.item:setMenuSprite(3, SpriteBank.getSprite('icon_shield_3'))
  end
}

function ItemShield:getType()
  return 'item_shield'
end

function ItemShield:onTransformChanged()
  self.hitbox:onTransformChanged()
end

function ItemShield:onEquip()
  local shieldState = self:getPlayer():getStateFromCollection('player_shield_state')
  shieldState.shield = self
  self:getPlayer():beginConditionState(shieldState)
  return true
end

function ItemShield:isBlocking()
  return self.hitbox:isEnabled()
end

---@param dir4 integer
function ItemShield:updateHitboxPlacement(dir4)
  local hitboxPlacement = SHIELD_HITBOX_PLACEMENTS[self:getPlayer():getAnimationDirection4()]
  self.hitbox:setOffset(hitboxPlacement.offsetX, hitboxPlacement.offsetY)
  self.hitbox:resize(hitboxPlacement.w, hitboxPlacement.h)
end

function ItemShield:startBlocking()
  self:updateHitboxPlacement(self:getPlayer():getAnimationDirection4())
  self.hitbox:setEnabled(true)
end

function ItemShield:stopBlocking()
  self.hitbox:setEnabled(false)
end

function ItemShield:onAwake()
  self.hitbox:entityAwake()
  self.hitbox:setCollisionTag(CollisionTag.shield)
  self.hitbox:addIgnoreHitbox(self:getPlayer().hitbox)
  self.hitbox:setEnabled(false)
end

function ItemShield:update()
  if self.hitbox:isEnabled() then
    self:updateHitboxPlacement(self:getPlayer():getAnimationDirection4())
    self.hitbox:update()
  end
end

function ItemShield:debugDraw(flags)
  if bit.band(flags, EntityDebugDrawFlags.HitBox) ~= 0 and self.hitbox then
    self.hitbox:debugDraw()
  end
end


---@param sender Hitbox
---@return boolean
function ItemShield:triggerOverrideInteractions(sender)
  if self.hitbox:isEnabled() and isColliding(self.hitbox, sender) then
    local senderEntity = sender.entity
    if senderEntity['getInteractionResolver'] then
      -- sender entity implements Interaction resolver api
      local interactionResolver = senderEntity['getInteractionResolver'](senderEntity)
      if interactionResolver:hasInteraction(self.hitbox.collisionTag) then
        local interaction = interactionResolver:getInteraction(self.hitbox.collisionTag)
        if interaction ~= nil then
          -- Let the sender resolve the interaction against the shield hitbox.
          interaction(senderEntity, self.hitbox)
          return true
        end
      end
    end
  end
  return false
end


return ItemShield
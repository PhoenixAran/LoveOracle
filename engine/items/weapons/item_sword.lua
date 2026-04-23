local Class = require 'lib.class'
local ItemWeapon = require 'engine.items.item_weapon'
local SpriteBank = require 'engine.banks.sprite_bank'
local Hitbox = require 'engine.components.hitbox'
local CollisionTag = require 'engine.enums.collision_tag'
local EntityDebugDrawFlags = require('engine.enums.flags.entity_debug_draw_flags').enumMap

---@class ItemSword : ItemWeapon
---@field hitbox Hitbox
---@field sprite AnimatedSpriteRenderer
local ItemSword = Class { __includes = ItemWeapon,
  ---@param self ItemSword 
  ---@param inventoryItem InventoryItem
  ---@param args table
  init = function(self, inventoryItem, args)
    ItemWeapon.init(self, inventoryItem, args)
    -- declare stuff that will be used in onTransformChanged BEFORE entity constructor
    self.hitbox = Hitbox(self)
    self.hitbox:setCollisionTag(CollisionTag.sword)

    -- TODO do sprite by level
    self.sprite = SpriteBank.build('player_sword', self)
    self.visible = false


    self.hitbox:setPhysicsLayer('hitbox_player')
    self.hitbox:setCollidesWithLayer('hitbox_enemy')
    self.hitbox.damageInfo.damage = 1
    self.hitbox.damageInfo.hitstunTime = 4
    self.hitbox.damageInfo.intangibilityTime = 18
    self.hitbox.damageInfo.knockbackSpeed = 200
    self.hitbox.damageInfo.knockbackTime = 8

    self.useParameters.usableWhileJumping = true
    self.useParameters.usableWhileInHole = true
    
    -- item configuration
    -- self.item.maxLevel = 3
    -- self.item:setMenuSprite(1, SpriteBank.getSprite('icon_sword_1'))
    -- self.item:setMenuSprite(2, SpriteBank.getSprite('icon_sword_2'))
    -- self.item:setMenuSprite(3, SpriteBank.getSprite('icon_sword_3'))
  end
}

function ItemSword:getType()
  return 'item_sword'
end

function ItemSword:onItemLevelUp()
  -- TODO adjust hitbox damage and stuff based on level
end

function ItemSword:onTransformChanged()
  self.hitbox:onTransformChanged()
end

function ItemSword:onAwake()
  self.sprite:entityAwake()
  self.hitbox:entityAwake()
  self.hitbox:addIgnoreHitbox(self:getPlayer().hitbox)
  self.hitbox:setEnabled(false)
end


function ItemSword:onButtonPressed()
  local swingSwordState = self:getPlayer():getStateFromCollection('player_swing_state')
  swingSwordState.weapon = self
  self:getPlayer():beginWeaponState(swingSwordState)
  return true
end

function ItemSword:update()
  if self.hitbox:isEnabled() then
    self.hitbox:update()
  end
  if self.sprite:isEnabled() then
    self.sprite:update()
  end
end

function ItemSword:drawOver()
  self.sprite:draw()
end

function ItemSword:debugDraw(flags)
  if bit.band(flags, EntityDebugDrawFlags.HitBox) ~= 0 and self.hitbox then
    self.hitbox:debugDraw()
  end
end

---@param direction4 integer
function ItemSword:swing(direction4)
  self:setVisible(true)
  self.hitbox:setEnabled(true)
  self.sprite:play('swing', direction4, true)
end

function ItemSword:endSwing()
  self:setVisible(false)
  self.hitbox:setEnabled(false)
  self.sprite:stop()
end

return ItemSword
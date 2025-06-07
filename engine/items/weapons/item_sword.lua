local Class = require 'lib.class'
local Item = require 'engine.items.item'
local SpriteBank = require 'engine.banks.sprite_bank'
local Hitbox = require 'engine.components.hitbox'
local CollisionTag = require 'engine.enums.collision_tag'

---@class ItemSword : Item
---@field hitbox Hitbox
---@field sprite AnimatedSpriteRenderer
local ItemSword = Class { __includes = Item,
  ---@param self ItemSword
  ---@param args table
  init = function(self, args)
    Item.init(self, args)
    -- declare stuff that will be used in onTransformChanged BEFORE entity constructor
    self.hitbox = Hitbox(self)
    self.hitbox:setCollisionTag(CollisionTag.sword)
    self.useParameters.usableWhileJumping = true
    self.useParameters.usableWhileInHole = true
    self.sprite = SpriteBank.build('player_sword', self)
    self.visible = false

    self.hitbox.damageInfo.damage = 1
    self.hitbox.damageInfo.hitstunTime = 10
    self.hitbox.damageInfo.intangibilityTime = 18
    self.hitbox.damageInfo.knockbackSpeed = 200
    self.hitbox.damageInfo.knockbackTime = 15
  end
}
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               
function ItemSword:onTransformChanged()
  self.hitbox:onTransformChanged()
end

function ItemSword:onAwake()
  self.hitbox:entityAwake()
  self.hitbox:addIgnoreHitbox(self.player.hitbox)
  self.hitbox:setEnabled(false)
end


function ItemSword:getType()
  return 'item_sword'
end

function ItemSword:onButtonPressed()
  local swingSwordState = self.player:getStateFromCollection('player_swing_state')
  swingSwordState.weapon = self
  self.player:beginWeaponState(swingSwordState)
  return true
end

function ItemSword:update()
  self.hitbox:update()
  self.sprite:update()
end

function ItemSword:drawAbove()
  self.sprite:draw()
end

function ItemSword:debugDraw()
  self.hitbox:debugDraw()
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
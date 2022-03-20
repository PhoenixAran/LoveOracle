local Class = require 'lib.class'
local Item = require 'engine.items.item'
local SpriteBank = require 'engine.utils.sprite_bank'
local Hitbox = require 'engine.components.hitbox'

local ItemSword = Class { __includes = Item,
  init = function(self, args)
    -- declare stuff that will be used in onTransformChanged BEFORE entity constructor
    self.hitbox = Hitbox(self)
    self.hitbox:setCollidesWithLayer('enemy')
    Item.init(self, args)
    self.useParameters.usableWhileJumping = true
    self.useParameters.usableWhileInHole = true
    self.sprite = SpriteBank.build('player_sword', self)
  end
}

function ItemSword:onTransformChanged()
  self.hitbox:onTransformChanged()
end

function ItemSword:getType()
  return 'item_sword'
end

function ItemSword:onButtonPress()
  local swingSwordState = self.player:getStateFromCollection('player_swing_state')
  swingSwordState.weapon = self
  self.player:beginWeaponState(swingSwordState)
  return true
end

function ItemSword:update(dt)
  self.hitbox:update(dt)
  self.sprite:update(dt)
end

function ItemSword:draw()
  self.sprite:draw()
  self.hitbox:debugDraw()
end

function ItemSword:swing(direction4)
  self.sprite:play('swing', direction4, true)
end

return ItemSword
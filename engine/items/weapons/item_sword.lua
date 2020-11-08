local Class = require 'lib.class'
local Item = require 'engine.items.item'

local ItemSword = Class { __includes = Item,
  init = function(self)
    Item.init(self)
    self.name = 'player_sword'
    self.useParameters.usableWhileJumping = true
    self.useParameters.usableWhileInHole = true
    
    self.sprite = spriteBank.build('player_sword')
    
    self:add(self.sprite)
  end
}

function ItemSword:getType()
  return 'item_sword'
end

function ItemSword:onButtonPress()
  local swingSwordState = self.player:getStateFromCollection('player_swing_state')
  swingSwordState.weapon = self
  self.player:beginWeaponState(swingSwordState)
  return true
end

function ItemSword:swing(direction)
  self.sprite:play('swing', direction, true)
end

return ItemSword
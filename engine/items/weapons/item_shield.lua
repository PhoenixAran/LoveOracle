local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local ItemWeapon = require 'engine.items.item_weapon'

---@class ItemShield : ItemWeapon
local ItemShield = Class { __includes = ItemWeapon,
  ---@param self ItemShield
  ---@param args table
  init = function(self, args)
    ItemWeapon.init(self, args)
    self.useParameters.usableWhileJumping = true
    self.useParameters.usableWithSword = truefac
    self.useParameters.usableWhileInHole = true
  end
}

function ItemShield:onEquip()
  local shieldState = self:getPlayer():getStateFromCollection('player_shield_state')
  shieldState.shield = self
  self:getPlayer():beginConditionState(shieldState)
  return true
end


function ItemShield:getType()
  return 'item_shield'
end

return ItemShield
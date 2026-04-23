local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Item = require 'engine.items.item'
local WeaponUseParameters = require 'engine.items.weapon_use_parameters'

---@class ItemWeapon : Item
---@field useParameters WeaponUseParameters
local ItemWeapon = Class { __includes = Item,
  init = function(self, inventoryItem, args)
    Item.init(self, inventoryItem, args)
    self.useParameters = WeaponUseParameters()
  end
}

function ItemWeapon:getType()
  return 'item_weapon'
end

function ItemWeapon:isTwoHanded()
  return self.useParameters.twoHanded
end

-- feel free to override this
function ItemWeapon:isUsable()
  local player = self:getPlayer()
  if not player:getStateParameters().canUseWeapons then
    return false
  elseif player:isInAir() and not self.useParameters.usableWhileJumping then
    return false
  elseif player:isInHole() and not self.useParameters.usableWhileInHole then
    return false
  elseif player:getWeaponState() ~= nil and
          player:getWeaponState():getType() == 'sword' and -- TODO: add sword state checks as time goes on
          not self.useParameters.usableWithSword then
    return false
  end
  -- TODO check if player is in minecart
  return true
end



return ItemWeapon
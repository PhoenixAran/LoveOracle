local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local ItemEquipment = require 'engine.items.item_equipment'
local WeaponUseParameters = require 'engine.items.weapon_use_parameters'

---@class ItemWeapon :ItemEquipment
---@field useParameters WeaponUseParameters
local ItemWeapon = Class { __includes = ItemEquipment,
  init = function(self, args)
    ItemEquipment.init(self, args)
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
  local player = self.player
  if not player:getStateParameters().canUseWeapons then
    return false
  elseif player:isInAir() and not self.useParameters.usableWhileJumping then
    return false
  elseif self.player:getWeaponState() ~= nil and
          self.player:getWeaponState():getType() == 'sword' and -- TODO: add sword state checks as time goes on
          not self.useParameters.usableWithSword then
    return false
  end
  -- TODO check if player is in hole
  return true
end



return ItemWeapon
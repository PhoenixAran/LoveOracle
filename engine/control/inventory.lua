local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local ItemBank = require 'engine.banks.item_bank'

local SLOT_SWORD = 1 -- should be hardcoded to always be equipped to sword if it exists
local SLOT_ITEM_1 = 2
local SLOT_ITEM_2 = 3

---@class Inventory
---@field items table
---@field equippedItems Item[]
---@field gameControl GameControl?
---@field piecesOfHeart number
---@field player Player
local Inventory = Class { __includes = SignalObject,
  init = function(self, gameControl)
    SignalObject.init(self)

    self.items = { }
    self.equippedItems = { }

    self.gameControl = gameControl or nil
    self.piecesOfHeart = nil
    self.player = nil
  end
}

-- connect player signals to inventory
function Inventory:setPlayer(player)
  self.player = player
end

function Inventory:getType()
  return 'inventory'
end

function Inventory:addItem(itemId)
  self.items[itemId] = ItemBank.getItem(itemId)
end

function Inventory:removeItem(itemId)
  self.items[itemId] = nil
end

function Inventory:equipItem(itemId, slot)
  
end

function Inventory:unequipItem(itemId, slot)

end

function Inventory:obtainItem(item)

end

function Inventory:unobtainItem(item)

end

function Inventory:setLevel(itemId, level)

end

function Inventory:setMaxLevel(itemId)

end

function Inventory:getSlotButton(slot)

end

function Inventory:isWeaponEquipped(weapon)

end

function Inventory:isWeaponButtonDown(id)

end

function Inventory:getWeapon(id)

end

function Inventory:getItems()

end

function Inventory:getItem(id)

end

function Inventory:containsItem(itemId)

end

function Inventory:isItemObtained(id)

end

function Inventory:isItemAvailable()

end

function Inventory:addAmmos(obtain, ammos)

end

function Inventory:addAmmo(obtain, ammo)

end

function Inventory:fillAllAmmo()

end

function Inventory:emptyAllAmmo()

end

function Inventory:obtainAmmo(ammo)

end

function Inventory:getAmmo(ammoId)

end

function Inventory:getAmmos()

end

function Inventory:containsAmmo(ammoId)

end

function Inventory:isAmmoObtained(ammoId)

end

function Inventory:isAmmoAvailable(ammoId)

end

function Inventory:isAmmoContainerAvailable(id)

end

function Inventory:getEquippedWeapons()

end

function Inventory:isTwoHandedEquipped()

end

function Inventory:getPiecesOfHeart()

end

function Inventory:getGameControl()
  return self.gameControl
end


return Inventory


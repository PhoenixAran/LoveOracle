local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local ItemBank = require 'engine.banks.item_bank'
local lume = require 'lib.lume'

---@class Inventory
---@field protectedSlots string[] list of slots that are protected and can only be set to certain items. See default values for examples
---@field items table<string, Item|ItemEquipment>
---@field ammos table<string, Ammo>
---@field equippedItems Item[]
---@field gameControl GameControl?
---@field piecesOfHeart number number of pieces of heart between 0 and 3
---@field player Player
local Inventory = Class { __includes = SignalObject,
  init = function(self, gameControl)
    SignalObject.init(self)

    self.protectedSLots = {
      'a', -- reserved for Roc feather when unlocked. It is also the interact button so it should not be used for anything else
      'b'  -- reserved for sword
    }

    self.items = { }
    self.equippedItems = { }
    self.equippedSlotItems = { }

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

function Inventory:removeItem(itemId)
  self.items[itemId] = nil
end

--- equip an item on the player
---@param item string|ItemEquipment the item to equip, either an item id or an ItemEquipment instance
---@param slot nil|string|string[] the slot(s) to equip the item to, if any
function Inventory:equipItem(item, slot)
  if slot ~= nil then
    if type(slot) == 'string' then
      assert(not lume.any(self.protectedSlots, slot))
    else
      if lume.count(slot) == 0 then
        error('Empty slot array provided to Inventory::equipItem')
      end
      for _, v in ipairs(slot) do
        assert(not lume.any(self.protectedSlots), v)
      end
    end
  end

  -- validate item
  ---@type ItemEquipment
  local equippableItem
  if type(item) == 'string' then
    equippableItem = ItemBank.getItem(item)
  end
  assert(equippableItem:isEquippable(), 'Cannot equip non-equippable item')

  -- equip item
  equippableItem:clearUseButtons()
  if slot ~= nil then
    equippableItem:addUseButtons(slot)
  end
  equippableItem:equip()

  -- add to inventory's internal items collection so we can keep track of whats currently equipped
  lume.push(self.items, equippableItem)
end

function Inventory:unequipItem(item)
  ---@type ItemEquipment
  local equippableItem
  if type(item) == 'string' then
    equippableItem = ItemBank.getItem(item)
  end

  assert(equippableItem:isEquippable(), 'Cannot unequip non-equippable item')

  equippableItem:unequip()
  equippableItem:setPlayer(nil)
  equippableItem:clearUseButtons()

  -- remove from our inventory's internal items collection
  lume.remove(self.items, equippableItem)
end

function Inventory:unequipItemBySlot(slot)
  for _, item in ipairs(self.items) do
    if item:isEquippable() then
      ---@type ItemEquipment
      local equippableItem = item
      if lume.any(equippableItem:getUseButtons(), slot) then
        self:unequipItem(equippableItem)
        break
      end
    end
  end
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

function Inventory:getInspectorProperties()
  -- TODO would be extremely useful
  error('Inventory:getInspectorProperties not implemented')
end

return Inventory


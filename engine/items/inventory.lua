local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local ItemBank = require 'engine.banks.item_bank'
local lume = require 'lib.lume'


---@class Inventory
---@field protectedSlots string[] list of slots that are protected and can only be set to certain items. See default values for examples
---@field items table<string, (Item|ItemEquipment)> items currently in the inventory, indexed by item id
---@field lostItems table<string,(Item|ItemEquipment)> items that have been lost, indexed by item id. This is used to track items that have been lost but not yet re-obtained, so that they can be made unavailable in the UI and other places. Once an item is re-obtained, it will be removed from this list
---@field ammos table<string, Ammo>
---@field gameControl GameControl?
---@field piecesOfHeart number number of pieces of heart between 0 and 3
---@field player Player
local Inventory = Class { __includes = SignalObject,
  init = function(self, gameControl)
    SignalObject.init(self)

    -- TODO prevent sprint boots button, to whatever it will be
    self.protectedSlots = {
      'a', -- reserved for Roc feather when unlocked. It is also the interact button and swim button when in water
    }

    self.items = { }
    self.lostItems = { }

    self.gameControl = gameControl or nil
    self.piecesOfHeart = nil
    self.player = nil
  end
}

-- connect player signals to inventory
function Inventory:setPlayer(player)
  self.player = player
end

---@return table<string, ItemEquipment>?
function Inventory:getEquippedItems()
  if self.player then
    return self.player.slotItems
  end
  return nil
end

function Inventory:getType()
  return 'inventory'
end

function Inventory:getItem(itemId)
  return self.items[itemId]
end

function Inventory:containsItem(itemId)
  if type(itemId) == 'table' then
    itemId = itemId:getItemId()
  end
  return self:getItem(itemId) ~= nil
end

function Inventory:removeItem(itemId)

  local item = self.items[itemId]
  if item then
    local equippedItems = self:getEquippedItems()
    if not equippedItems then
      return
    end
    if lume.any(equippedItems, item) then
      ---@type ItemEquipment
      local equippableItem = item
      self:unequipItem(equippableItem)
    end
    self.items[itemId] = nil
  end
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
      for _, v in pairs(slot) do
        assert(not lume.any(self.protectedSlots, v))
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
  equippableItem:setPlayer(self.player)
  equippableItem:equip()
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

---@param item Item|ItemEquipment|string
function Inventory:obtainItem(item)
  if type(item) == 'string' then
    item = ItemBank.getItem(item)
  end
  if not self:containsItem(item) then
    self.items[item:getItemId()] = item
  end
  self.lostItems[item:getItemId()] = nil
end

function Inventory:unobtainItem(item)
  if type(item) == 'string' then
    item = self:getItem(item)
  end
  
  if self:containsItem(item) then
    lume.remove(self.items, item)
    if item.unequip then
      item:unequip()
    end
  end
end

function Inventory:setLevel(itemId, level)
  local item = self:getItem(itemId)
  if item then
    item:setLevel(level)
  end
end

function Inventory:setMaxLevel(itemId)
  local item = self:getItem(itemId)
  if item then
    item:setMaxLevel()
  end
end

function Inventory:getItems()
  return self.items
end

function Inventory:isItemAvailable(item)
  if type(item) == 'string' then
    item = self:getItem(item)
  end
  return item ~= nil and not self.lostItems[item:getItemId()]
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


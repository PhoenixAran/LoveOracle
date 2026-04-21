local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local ItemBank = require 'engine.banks.item_bank'
local lume = require 'lib.lume'

-- TODO refactor to use InventoryItem instead of ItemData directly
-- necessary to support a more flexible inventory system like harvest moon

---@class Inventory
---@field protectedSlots string[] list of slots that are protected and can only be set to certain items. See default values for examples
---@field items ItemData[] items currently in the inventory
---@field lostItems ItemData[] items that have been lost, indexed by item id. This is used to track items that have been lost but not yet re-obtained, so that they can be made unavailable in the UI and other places. Once an item is re-obtained, it will be removed from this list
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

function Inventory:getType()
  return 'inventory'
end

-- connect player signals to inventory
function Inventory:setPlayer(player)
  self.player = player
end

--- get equipped button slot items
---@return table<string, Item>?
function Inventory:getEquippedButtonSlotItems()
  if self.player then
    return self.player.buttonSlotItems
  end
  return nil
end

-- TODO get method to get eqipped non button slot items

--- get all equipped items, including both button slot and non-button slot items
--- @return 
function Inventory:getAllEquippedItems()
  -- no non button slot items implemented yet
  local equipedItems = { }
  local equippedItems =  self:getEquippedButtonSlotItems() 
  for _, item in pairs(equippedItems) do
    lume.push(equipedItems, item)
  end
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

--- equip an item on the player
---@param itemData string|ItemData the item to equip, either an item id or an ItemData instance
---@param slot nil|string|string[] the slot(s) to equip the item to, if any
function Inventory:equipItem(itemData, slot)
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
  ---@type ItemData
  local equippableItem
  if type(itemData) == 'string' then
    itemData = ItemBank.getItem(itemData)
  end
  assert(itemData:isEquippable(), 'Cannot equip non-equippable item')

  -- create item
  local item = itemData:createItem()

  if item:isButtonSlotItem() then
    assert(slot, 'Button slot item must be equipped to a slot')
    -- TODO handle equipping to multiple slots for two handed items. Like the great fairy sword
    item:clearUseButtons()
    item:addUseButtons(slot)
    item:setPlayer(self.player)
    item:equip()
  else
    error('Non button slot items not supported yet')
    -- TODO things like rings and different tunics should be equippable but not button slot items. For now, just equip them to the first slot, but eventually they should be able to be equipped 
    -- without a slot or to specific non-button slots
  end
end

---@param itemData ItemData|string
function Inventory:unequipItem(itemData)
  if type(itemData) == 'string' then
    itemData = ItemBank.getItem(itemData)
  end

  assert(itemData:isEquippable(), 'Cannot unequip non-equippable item')
  
  local allEquippedItems = self:getAllEquippedItems()
  if allEquippedItems then
    local equippedItemIndex = lume.find(allEquippedItems, function(equippedItem)
      return equippedItem:getItemId() == itemData:getItemId()
    end)
    if equippedItemIndex then
      local equippedItem = allEquippedItems[equippedItemIndex]
      equippedItem:unequip()
      equippedItem:setPlayer(nil)
      equippedItem:clearUseButtons()
    end
  end

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

---@param itemData ItemData|string
function Inventory:addItem(itemData)
  if type(itemData) == 'string' then
    itemData = ItemBank.getItem(itemData)
  end
  lume.push(self.items, itemData)
end


---@param itemData ItemData|string
function Inventory:removeItem(itemData)
  if type(itemData) == 'string' then
    itemData = ItemBank.getItem(itemData)
  end
  
  -- remove item from inventory
  local itemData = self.items[itemData:getItemId()]
  self.items[itemData:getItemId()] = nil
  if itemData then
    local allEquippedItems = self:getAllEquippedItems()
    if not allEquippedItems then
      return
    end
    local equippedItem = lume.find(allEquippedItems, function(equippedItem)
      return equippedItem:getItemId() == itemId
    end)
    if equippedItem then
      self:unequipItem(equippedItem)
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


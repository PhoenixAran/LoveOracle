local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local ItemBank = require 'engine.banks.item_bank'
local lume = require 'lib.lume'
local InventoryItem = require 'engine.items.inventory_item'

-- TODO refactor to use InventoryItem instead of ItemData directly
-- necessary to support a more flexible inventory system like harvest moon

---@class Inventory
---@field protectedSlots string[] list of slots that are protected and can only be set to certain items. See default values for examples
---@field items InventoryItem[] items currently in the inventory
---@field lostItems InventoryItem[] items that have been lost, indexed by item id. This is used to track items that have been lost but not yet re-obtained, so that they can be made unavailable in the UI and other places. Once an item is re-obtained, it will be removed from this list
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

---@param inventoryItemId integer
---@return InventoryItem? the inventory item with the given id, or nil if no such item exists in the inventory
function Inventory:getItem(inventoryItemId)
  for _, inventoryItem in ipairs(self.items) do
    if inventoryItem:getId() == inventoryItemId then
      return inventoryItem
    end
  end
  return nil
end

--- if the inventory contains an inventory item with the given instance id 
---@param inventoryItemId integer
---@return boolean
function Inventory:containsItem(inventoryItemId)
  return self:getItem(inventoryItemId) ~= nil
end

--- equip an item on the player
---@param inventoryItem InventoryItem|integer the inventory item to equip, either an InventoryItem instance or an inventory item id
---@param slot nil|string|string[] the slot(s) to equip the item to, if any
function Inventory:equipItem(inventoryItem, slot)
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

  if type(inventoryItem) == 'number' then
    ---@cast inventoryItem integer
    local inventoryItemId = inventoryItem
    inventoryItem = self:getItem(inventoryItemId)
    if inventoryItem == nil then
      return
    end
  end


  assert(inventoryItem:getItemData():isEquippable(), 'Cannot equip non-equippable item')

  -- create item
  local item = inventoryItem:createItem()

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

---@param inventoryItem InventoryItem|integer the inventory item to unequip, either an InventoryItem instance or an inventory item id
function Inventory:unequipItem(inventoryItem)
  if type(inventoryItem) == 'number' then
    ---@cast inventoryItem integer
    local inventoryItemId = inventoryItem
    inventoryItem = self:getItem(inventoryItemId)
    if inventoryItem == nil then
      return
    end
  end

  assert(inventoryItem:getItemData():isEquippable(), 'Cannot unequip non-equippable item')

  local allEquippedItems = self:getAllEquippedItems()
  if allEquippedItems then
    local equippedItemIndex = lume.find(allEquippedItems, function(equippedItem)
      return equippedItem:getInventoryItemId() == inventoryItem:getId()
    end)
    if equippedItemIndex then
      local equippedItem = allEquippedItems[equippedItemIndex]
      equippedItem:unequip()
      equippedItem:setPlayer(nil)
      equippedItem:clearUseButtons()
    end
  end
end

function Inventory:unequipItemByButtonSlot(slot)
  local buttonSlotItems = self:getEquippedButtonSlotItems()
  for buttonSlot, item in pairs(buttonSlotItems) do
    if buttonSlot == slot then
      self:unequipItem(item:getInventoryItemId())
      break
    end
  end
end

---@param itemData ItemData|string
---@return InventoryItem
function Inventory:addItem(itemData)
  if type(itemData) == 'string' then
    itemData = ItemBank.getItem(itemData)
  end
  local inventoryItem = InventoryItem(itemData)
  lume.push(self.items, inventoryItem)
  return inventoryItem
end


---@param inventoryItem InventoryItem|integer
---@return InventoryItem? the removed inventory item, or nil if the item was not found in the inventory
function Inventory:removeItem(inventoryItem)
  if type(inventoryItem) == 'number' then
    ---@cast inventoryItem integer
    local instanceId = inventoryItem
    inventoryItem = self:getItem(instanceId)
    if inventoryItem == nil then
      return nil
    end
  end

  -- unequip item
  self:unequipItem(inventoryItem)

  -- remove InventoryItem from inventory
  if not lume.find(self.items, inventoryItem) then
    return nil
  end
  lume.remove(self.items, inventoryItem)
  return inventoryItem
end

function Inventory:setLevel(itemId, level)
  local item = self:getItem(itemId)
  if item then
    item:setLevel(level)
  end
end

function Inventory:setMaxLevel(itemId)
  error('not implemented')
end

function Inventory:getItems()
  return self.items
end

---@param itemDataId string itemData string
---@return boolean
function Inventory:isItemAvailable(itemDataId)
  for _, inventoryItem in ipairs(self.items) do
    if inventoryItem:getItemData():getItemId() == itemDataId then
      return true
    end
  end
  return false
end

function Inventory:addAmmos(obtain, ammos)
  error('not implemented')
end

function Inventory:addAmmo(obtain, ammo)
  error('not implemented')
end

function Inventory:fillAllAmmo()
  error('not implemented')
end

function Inventory:emptyAllAmmo()
  error('not implemented')
end

function Inventory:obtainAmmo(ammo)
  error('not implemented')
end

function Inventory:containsAmmo(ammoId)
  error('not implemented')
end

function Inventory:isAmmoObtained(ammoId)
  error('not implemented')
end

function Inventory:isAmmoAvailable(ammoId)
  error('not implemented')
end

function Inventory:isAmmoContainerAvailable(id)
  error('not implemented')
end

function Inventory:isTwoHandedEquipped()
  error('not implemented')
end 

function Inventory:getPiecesOfHeart()
  error('not implemented')
end

function Inventory:getGameControl()
  return self.gameControl
end

function Inventory:getInspectorProperties()
  -- TODO would be extremely useful
  error('Inventory:getInspectorProperties not implemented')
end

return Inventory


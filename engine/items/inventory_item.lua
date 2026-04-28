local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local ItemBank = require 'engine.banks.item_bank'

local InstanceId = 1
local function getInstanceId()
  local id = InstanceId
  InstanceId = InstanceId + 1
  return id
end


---@class InventoryItem
---@field itemData ItemData underlying item data for this inventory item
---@field id integer unique id for this instance of the item, used to track individual items in the inventory and distinguish between multiple copies of the same item
---@field level integer level of the item, used to determine which item type to use when creating an instance of the item. This is separate from the level in ItemData because it can be upgraded or downgraded independently of the underlying item data
---@field amount integer? amount of the item, used for items that are amount based. Nil if not ammount based
local InventoryItem = Class {
  ---@param self InventoryItem
  ---@param itemData ItemData|string
  ---@param level integer?
  ---@param amount integer?
  init = function(self, itemData, level, amount)
    if type(itemData) == 'string' then
      itemData = ItemBank.getItem(itemData)
    end
    self.itemData = itemData
    self.id = getInstanceId()
    self.level = itemData.level or 1
    self.amount = amount
  end
}

function InventoryItem:getType()
  return 'inventory_item'
end

function InventoryItem:getItemData()
  return self.itemData
end

function InventoryItem:getId()
  return self.id
end

---@return integer level
function InventoryItem:getLevel()
  return self.level
end

function InventoryItem:setLevel(level)
  self.level = level
end

function InventoryItem:getAmount()
  return self.amount
end

---@param amount integer
function InventoryItem:setAmount(amount)
  self.amount = lume.clamp(amount, 0, self.itemData:getMaxAmount())
end

---create an item instance from this inventory item
---@return Item
function InventoryItem:createItem()
  local level = self:getLevel()
  if not self.itemData:isLeveled() then
    level = 1
  end

  local initArgs = self.itemData.itemTypeArgs[level] or { }
  return self.itemData.itemTypes[level](self, initArgs)
end

function InventoryItem:getMenuSprite()
  local level = self:getLevel()
  if not self.itemData:isLeveled() then
    level = 1
  end
  if lume.count(self.itemData.menuSprites) == 1 then
    level = 1
  end
  return self.itemData.menuSprites[level]
end

function InventoryItem:getDescription()
  local level = self:getLevel()
  if not self.itemData:isLeveled() then
    level = 1
  end
  if lume.count(self.itemData.descriptions) == 1 then
    level = 1
  end
  return self.itemData.descriptions[level]
end

return InventoryItem
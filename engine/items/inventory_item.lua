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
---@field instanceId integer unique id for this instance of the item, used to track individual items in the inventory and distinguish between multiple copies of the same item
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
    self.instanceId = getInstanceId()
    self.level = itemData.level or 1
    self.amount = amount
  end
}

return InventoryItem
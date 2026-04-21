local Class = require 'lib.class'
local lume = require 'lib.lume'
local ItemData = require 'engine.items.item_data'

-- export type
local ItemBank = {
  items = { }
}

--- register item data
---@param item ItemData
function ItemBank.registerItem(item)
  local itemId = item:getItemId()
  assert(not ItemBank.items[itemId], 'ItemBank already has item with key ' .. itemId)
  ItemBank.items[itemId] = item
end

--- get item data by item id
---@param itemId string
---@return ItemData
function ItemBank.getItem(itemId)
  local itemData = ItemBank.items[itemId]
  assert(itemData, 'ItemBank does not have item with key ' .. itemId)
  return itemData
end

--- create item data by item id
---@param itemId string?
---@return ItemData
function ItemBank.createItemData(itemId)
  return ItemData(itemId)
end

return ItemBank
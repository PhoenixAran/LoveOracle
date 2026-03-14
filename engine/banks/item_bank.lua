local Class = require 'lib.class'
local lume = require 'lib.lume'

local ItemData = require 'engine.items.item_data'

-- export type
local ItemBank = {
  items = { }
}

--- register item
---@param item Item|ItemEquipment
function ItemBank.registerItem(item)
  local itemId = item:getName()
  assert(not ItemBank.items[itemId], 'ItemBank already has ItemData with key ' .. itemId)
  ItemBank.items[itemId] = item
end

--- get item by id
---@param itemId string
---@return Item|ItemEquipment
function ItemBank.getItem(itemId)
  local itemData = ItemBank.items[itemId]
  assert(itemData, 'ItemBank does not have ItemData with key ' .. itemId)
  return itemData
end

return ItemBank
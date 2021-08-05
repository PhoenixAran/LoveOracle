local Class = require 'lib.class'
local lume = require 'lib.lume'

local ItemData = require 'engine.items.item_data'

-- export type
local ItemBank = {
  items = { }
}

function ItemBank.registerItem(itemId, itemData)
  assert(not ItemBank.items[itemId], 'ItemBank already has ItemData with key ' .. itemId)
  items[itemId] = itemData
end

function ItemBank.getItem(itemId)
  local itemData = ItemBank.items[itemId]
  assert(itemData, 'ItemBank does not have ItemData with key ' .. itemId)
  return itemData
end

-- quick access to ItemData class for data scripting
function ItemBank.createItemData(itemId, category, name)
  assert(itemId, 'Item ID cannot be nil')
  return ItemData(itemId, category, name)
end

return ItemBank
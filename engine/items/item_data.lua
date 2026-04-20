local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'

-- Class that ItemSlot will utilise
-- TODO refactor inventory to use ItemData instead of Item
-- TODO also refactor item_equipment -> item. Original item class will be removed
-- ItemWeapon will then extend Item 

---@class ItemData
---@field name string
---@field category string?
---@field itemId string
---@field maxLevel integer
---@field level integer
---@field menuSprites Sprite|Sprite[]
---@field itemTypes string[]
---@field itemTypeArgs table[] arguments to pass to the item type when creating an instance of it, indexed by level
---@field amountBased boolean
---@field ammoBased boolean
local ItemData = Class {
  init = function(self, itemId)
    assert(itemId, 'Item ID cannot be null')
    SignalObject.init(self)
    self.name = nil
    self.category = nil
    self.itemId = itemId
    self.level = 1
    self.maxLevel = 0
    self.menuSprites = { }
    self.itemTypes = { }
    self.itemTypeArgs = { }
    self.amountBased = false
  end
}

function ItemData:getType()
  return 'item_data'
end

function ItemData:getId()
  return self.itemId
end

function ItemData:getName()
  return self.name
end

function ItemData:setCategory(category)
  self.category = category
end

function ItemData:getCategory()
  return self.category
end

function ItemData:setName(name)
  self.name = name
end

function ItemData:setAmountBased(isAmountBased)
  self.amountBased = isAmountBased
end

function ItemData:isLeveled()
  return self.maxLevel > 0
end

function ItemData:setMaxLevel(level)
  if level then
    self.maxLevel = level
  else
    self.maxLevel = 0
  end
end

---@param level integer|Sprite[]
---@param sprite Sprite?
function ItemData:setMenuSprites(level, sprite)
  if type(level) == 'table' then
    lume.push(self.menuSprites, unpack(level))
  else
    self.menuSprites[level] = sprite
  end
end

function ItemData:getMenuSprites()
  return self.menuSprites
end

---@param level integer|string[]
---@param modulePath string? the require path to the Item type
function ItemData:setItemTypes(level, modulePath, initArgs)
  if type(level) == 'table' then
    lume.push(self.itemTypes, unpack(level))
  else
    self.itemTypes[level] = modulePath
  end
end

return ItemData

local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local SpriteBank = require 'engine.banks.sprite_bank'
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
---@field itemTypes table[]
---@field itemTypeArgs table[] arguments to pass to the item type when creating an instance of it, indexed by level
---@field amountBased boolean
---@field maxAmount integer
---@field ammoBased boolean
---@field ammoType string?
---@field buttonSlotItem boolean if item gets assigned a button slot when equipped
---@field isEquippable boolean if item can be equipped
---@field descriptions string[] item descriptions for each level. If only one description is given, it will be used for all levels
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
    self.ammoType = nil
    self.buttonSlotItem = false
    self.equippable = false
    self.maxAmount = 1
    self.descriptions = { '' }
  end
}

function ItemData:getType()
  return 'item_data'
end

function ItemData:getItemId()
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

--- set menu sprites for this item. If an array of sprites is given, each sprite will be assigned
--- to its corresponding level via array index
---@param level integer|(Sprite|string)[]
---@param sprite (Sprite|string)? the sprite or sprite bank id
function ItemData:setMenuSprite(level, sprite)
  if type(level) == 'table' then
    for i, sprite in ipairs(level) do
      if type(sprite) == 'string' then
        sprite = SpriteBank.getSprite(sprite)
      end
      self.menuSprites[i] = sprite
    end
  else
    if type(sprite) == 'string' then
      sprite = SpriteBank.getSprite(sprite)
    end
    self.menuSprites[level] = sprite
  end
end

function ItemData:getMenuSprites()
  return self.menuSprites
end

--- get menu sprite
---@param level integer
---@return Sprite
function ItemData:getMenuSprite(level)
  return self.menuSprites[level]
end

---@param level integer
---@param module string|table path to itemtype or Itemtype
---@param initArgs table? the arguments to pass to the item
function ItemData:setItemType(level, module, initArgs)
  if type(module) == 'string' then
    module = require(module)
  end
  self.itemTypes[level] = module
  self.itemTypeArgs[level] = initArgs
end

--- sets if item, if equippable, should be assigned to a button slot
---@param value boolean
function ItemData:setButtonSlotItem(value)
  self.buttonSlotItem = value
end

function ItemData:isButtonSlotItem()
  return self.buttonSlotItem
end

function ItemData:setEquippable(value)
  self.equippable = value
end

function ItemData:isEquippable()
  return self.equippable
end

function ItemData:getMaxAmount()
  return self.maxAmount
end

function ItemData:setMaxAmount(maxAmount)
  assert(maxAmount > 0, 'Max amount must be greater than 0')
  self.maxAmount = maxAmount
end

function ItemData:getDescription(level)
  if lume.count(self.descriptions) == 1 then
    return self.descriptions[1]
  else
    return self.descriptions[level]
  end
end

return ItemData

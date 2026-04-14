local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'


---@class Item : SignalObject
---@field id string
---@field menuSprites Sprite[] sprites shown in menu, indexed by level
---@field name string[] names indexed by level
---@field description string[] descriptions indexed by level
---@field maxLevel integer max level of this item
---@field message string[] message shown when item is obtained, indexed by level
---@field price integer[] price of item in shop, indexed by level
---@field player Player
---@field level integer
---@field ammo Ammo[] ammo types used by this item, indexed by level
---@field levelUpAmmo boolean if ammo type should match level. If not, ammo[1] will be used for all levels
---@field maxAmmo integer[] max ammo for this item, indexed by level
---@field itemRewardHoldsType ItemRewardsHoldType how the player visually holds the reward when collected
---@field lost boolean TODO deprecate
---@field obtained boolean TODO deprecate
local Item = Class { __includes = SignalObject,
  init = function(self, args)
    SignalObject.init(self, args)
    self.id = args.id or nil
    self.names = { }
    self.name = nil
    self.level = 0
    self.prices = { }
    self.menuSprites = { }
    self.player = nil
    self.itemRewardsHoldType = args.itemRewardsHoldType or 0
    self.lost = args.lost or false
    self.obtained = args.obtained or false
  end
}

function Item:getType()
  return 'item'
end

function Item:getItemId()
  return self.id
end

function Item:isEquippable()
  return false
end

function Item:getName()
  return self.name
end

function Item:getPlayer()
  return self.player
end

---@param player Player?
function Item:setPlayer(player)
  self.player = player
end

function Item:getLevel()
  return self.level
end

--- plain items cannot trigger override interactions
function Item:canTriggerOverrideInteractions()
  return false
end

---@param sender Hitbox
---@return boolean
function Item:triggerOverrideInteractions(sender)
  return false
end

function Item:setLevel(level)
  self.level = level
end

function Item:setMaxLevel()
  self.level = self.maxLevel
end

--- formerly onInitialize
--- called when item is added to the Inventory list
function Item:onAddedToInventoryList()
end

--- called when the item's level has increased
function Item:onItemLevelUp()
end

--- called when the item is obtained
function Item:onObtained()
end

--- called when the item is unobtained
function Item:onUnobtained()
end

--- called when the item is lost
function Item:onLost()
end

--- called when the item has been reobtained after being lost
function Item:onReobtained()
end

-- convenience methods
function Item:setMenuSprite(level, sprite)
  self.menuSprites[level] = sprite
end

function Item:getMenuSprite(level)
  if level == nil then 
    level = self.level
  end
  return self.menuSprites[level]
end

function Item:setPrice(level, price)
  self.price[level] = price
end

return Item
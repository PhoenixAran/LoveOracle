local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local Input = require('engine.singletons').input

---@class Item : Entity
---@field id string
---@field name string[] names indexed by level
---@field description string[] descriptions indexed by level
---@field maxLevel integer max level of this item
---@field message string[] message shown when item is obtained, indexed by level
---@field price integer[] price of item in shop, indexed by level
---@field player Player
---@field level integer
---@field useButtons string[]
---@field ammo Ammo[] ammo types used by this item, indexed by level
---@field levelUpAmmo boolean if ammo type should match level. If not, ammo[1] will be used for all levels
---@field maxAmmo integer[] max ammo for this item, indexed by level
---@field itemRewardHoldsType ItemRewardsHoldType how the player visually holds the reward when collected
---@field isLost boolean
---@field isObtained boolean
local Item = Class { __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)
    self.id = args.id or nil
    self.names = { }
    self.name = nil
    self.level = 0
    self.useButtons = { }
    self.prices = { }
    self.player = nil
    self.itemRewardsHoldType = args.itemRewardsHoldType or 0
    self.isLost = args.isLost or false
    self.isObtained = args.isObtained or false
  end
}

function Item:getType()
  return 'item'
end

function Item:isEquippable()
  return false
end

function Item:getName()
  return self.name
end

function Item:onAwake()

end


function Item:getPlayer()
  return self.player
end

function Item:setPlayer(player)
  self.player = player
  self:setPosition(player:getPosition())
end

function Item:getLevel()
  return self.level
end

function Item:getUseButton()
  return self.useButtons
end

function Item:isButtonDown()
  for _, button in ipairs(self.useButtons) do
    if Input:down(button) then
      return true
    end
  end
  return false
end

function Item:isButtonPressed()
  for _, button in ipairs(self.useButtons) do
    if Input:pressed(button) then
      return true
    end
  end
  return false
end

---@param sender Hitbox
function Item:overridesInteraction(sender)
end

-- called when assigned buttons are down
function Item:onButtonDown()
  
end

-- called when items are pressed this frame
function Item:onButtonPressed()
  return false
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

function Item:update()
end

function Item:draw()
end

function Item:interrupt()
  
end

function Item:drawUnder()

end

function Item:drawOver()

end

return Item
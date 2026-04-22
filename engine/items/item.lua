local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Entity = require 'engine.entities.entity'
local Input = require('engine.singletons').input

--- Item that can be equipped
--- TODO Item should have a generic implemenation where the character just holds it above their head and they can
--- gift it to NPCs or throw it away, like Harvest Moon
---@class Item : Entity
---@field inventoryItem InventoryItem underlying item item record for this item
---@field itemData ItemData underlying item data for this item, accessed through inventoryItem
---@field useButtons string[]
---@field equipped boolean
---@field player Player
---@field level integer
local Item = Class { __includes = Entity,
  init = function(self, inventoryItem, args)
    Entity.init(self, args)
    self.inventoryItem = inventoryItem
    self.itemData = inventoryItem:getItemData()
    self.equipped = false
    self.useButtons = { }
    self.player = nil
    self.level = inventoryItem:getLevel()
  end
}

function Item:getType()
  return 'item'
end

function Item:isEquippable()
  return self.itemData:isEquippable()
end

function Item:isButtonSlotItem()
  return self.itemData:isButtonSlotItem()
end

---@return string itemId item id for from the underlying item data record for this item
function Item:getItemId()
  return self.itemData:getItemId()
end

---@return integer inventoryItemId unique id from the underlying inventory item record for this item, used to track individual items in the inventory and distinguish between multiple copies of the same item
function Item:getInventoryItemId()
  return self.inventoryItem:getId()
end

function Item:getItemData()
  return self.itemData
end

function Item:getInventoryItem()
  return self.inventoryItem
end

---@param player Player?
function Item:setPlayer(player)
  self.player = player
  if player then
    self:setPosition(player:getPosition())
  end
end

function Item:getPlayer()
  return self.player
end

---@param level integer?
function Item:getMenuSprite(level)
  if level == nil then
    level = self.level
  end
  return self.itemData:getMenuSprite(level)
end

function Item:getLevel()
  return self.level
end

--- item equipment can trigger override interactions
--- @return boolean
function Item:canTriggerOverrideInteractions()
  return true
end

---@param sender Hitbox
---@return boolean
function Item:triggerOverrideInteractions(sender)
  return false
end

function Item:isEquipped()
  return self.equipped
end

function Item:isUsable()
  return false
end

function Item:clearUseButtons()
  lume.clear(self.useButtons)
end

--- assign use buttons
---@param button string|string[]
function Item:addUseButtons(button)
  if type(button) == 'string' then
    lume.push(self.useButtons, button)
  elseif type(button) == 'table' then
    for _, b in ipairs(button) do
      lume.push(self.useButtons, b)
    end
  end
end

function Item:getUseButtons()
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

-- called when assigned buttons are down
function Item:onButtonDown()
end

function Item:isButtonPressed()
  for _, button in ipairs(self.useButtons) do
    if Input:pressed(button) then
      self:onButtonPressed()
      return true
    end
  end
  return false
end

-- called when items are pressed this frame
function Item:onButtonPressed()
  return false
end

function Item:equip()
  local player = self:getPlayer()

  assert(player, 'Item equipment cannot be equipped without player instance being set')
  assert(lume.count(self.useButtons), 'Item equipment cannot be equipped without buttons being set')

  if not self.equipped then
    -- equip item
    player:equipItem(self)
    self.equipped = true
    self:onEquip()
  end
end

function Item:unequip()
local player = self:getPlayer()
  if self.equipped then
    -- unequip item
    player:unequipItem(self)
    self.equipped = false
    self:onUnequip()
  end
end

function Item:onEquip()
end

function Item:onUnequip()
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
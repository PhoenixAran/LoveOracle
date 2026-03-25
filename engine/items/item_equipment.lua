local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Entity = require 'engine.entities.entity'
local Item = require 'engine.items.item'
local Input = require('engine.singletons').input

---@class ItemEquipment : Entity
---@field item Item the item this equipment represents
---@field useButtons string[]
---@field equipped boolean
local ItemEquipment = Class { __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)
    if args.item then
      self.item = args.item
    else
      self.item = Item(args)
    end
    self.equipped = false
    self.useButtons = { }
  end
}

function ItemEquipment:getType()
  return 'item_equipment'
end

-- Item api
function ItemEquipment:isEquippable()
  return true
end

function ItemEquipment:getPlayer()
  return self.item:getPlayer()
end

---@param player Player?
function ItemEquipment:setPlayer(player)
  self.item:setPlayer(player)
  if player then
    self:setPosition(player:getPosition())
  end
end


function ItemEquipment:getLevel()
  return self.item:getLevel()
end

--- formerly onInitialize
--- called when item is added to the Inventory list
function ItemEquipment:onAddedToInventoryList()
  self.item:onAddedToInventoryList()
end

--- called when the item's level has increased
function ItemEquipment:onItemLevelUp()
  self.item:onItemLevelUp()
end

--- called when the item is obtained
function ItemEquipment:onObtained()
  self.item:onObtained()
end

--- called when the item is unobtained
function ItemEquipment:onUnobtained()
  self.item:onUnobtained()
end

--- called when the item is lost
function ItemEquipment:onLost()
  self.item:onLost()
end

--- called when the item has been reobtained after being lost
function ItemEquipment:onReobtained()
  self.item:onReobtained()
end

-- ItemEquipment api

--- If item when equipped, should occupy a slot
--- This is determined by checking if any useButtons are assigned
--- Passive items such as armors should not take up a slot
---@return boolean
function ItemEquipment:isSlotItem()
  return lume.any(self.useButtons)
end

function ItemEquipment:isEquipped()
  return self.isEquipped
end

function ItemEquipment:isUsable()
  return false
end

function ItemEquipment:clearUseButtons()
  lume.clear(self.useButtons)
end

--- assign use buttons
---@param button string|string[]
function ItemEquipment:addUseButtons(button)
  if type(button) == 'string' then
    lume.push(self.useButtons, button)
  elseif type(button) == 'table' then
    for _, b in ipairs(button) do
      lume.push(self.useButtons, b)
    end
  end
end

function ItemEquipment:getUseButtons()
  return self.useButtons
end

function ItemEquipment:isButtonDown()
  for _, button in ipairs(self.useButtons) do
    if Input:down(button) then
      return true
    end
  end
  return false
end

-- called when assigned buttons are down
function ItemEquipment:onButtonDown()
end

function ItemEquipment:isButtonPressed()
  for _, button in ipairs(self.useButtons) do
    if Input:pressed(button) then
      return true
    end
  end
  return false
end

-- called when items are pressed this frame
function ItemEquipment:onButtonPressed()
  return false
end

function ItemEquipment:equip(slotButton)
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

function ItemEquipment:unequip()
local player = self:getPlayer()
  if self.equipped then
    -- unequip item
    player:unequipItem(self)
    self.equipped = false
    self:onUnequip()
  end
end

function ItemEquipment:onEquip()
end

function ItemEquipment:onUnequip()
end

function ItemEquipment:update()
end

function ItemEquipment:draw()
end

function ItemEquipment:interrupt()
end

function ItemEquipment:drawUnder()
end

function ItemEquipment:drawOver()
end


return ItemEquipment
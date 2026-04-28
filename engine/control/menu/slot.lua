local Class = require 'lib.class'

---@class Slot
---@field positionX number
---@field positionY number
---@field width number
---@field slotGroup SlotGroup
---@field item InventoryItem
---@field enabled boolean
---@field connections table<Direction4, Slot|SlotGroup>
local Slot = Class {
  init = function(self, slotGroup, positionX, positionY, width)
    self.slotGroup = slotGroup
    self.positionX = positionX
    self.positionY = positionY
    self.width = width
    self.item = nil
    self.enabled = true
    self.connections = { }
  end
}

function Slot:getType()
  return 'slot'
end

function Slot:isEnabled()
  return self.enabled
end

function Slot:getPosition()
  return self.positionX, self.positionY
end

function Slot:select()
  self.slotGroup:setCurrentSlot(self)
  return self.slotGroup
end

---@param item InventoryItem
function Slot:setItem(item)
  self.item = item
end

---@return InventoryItem?
function Slot:getItem()
  return self.item
end

---@param dir4 Direction4
---@param slotConnection Slot|SlotGroup
function Slot:setConnection(dir4, slotConnection)
  if type(dir4) == 'table' then
    self.connections = dir4
  else
    self.connections[dir4] = slotConnection
  end
end

function Slot:getConnectionAt(dir4)
  return self.connections[dir4]
end

function Slot:draw()
  if self.item then
    -- TODO
  end
end


return Slot
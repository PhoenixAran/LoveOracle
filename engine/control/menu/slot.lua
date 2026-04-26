local Class = require 'lib.class'

---@class Slot
---@field positionX number
---@field positionY number
---@field width number
---@field slotGroup SlotGroup
---@field item Item|ItemEquipment
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

function Slot:select()
  self.slotGroup:setCurrentSlot(self)
  return self.slotGroup
end

---@param item Item|ItemEquipment
function Slot:setItem(item)
  self.item = item
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
    self.item:drawSlot(self.positionX, self.positionY)
  end
end


return Slot
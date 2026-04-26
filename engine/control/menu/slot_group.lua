local Class = require 'lib.class'
local Slot = require 'engine.control.menu.slot'
local lume = require 'lib.lume'

---@class SlotGroup
---@field slots Slot[]
---@field currentSlot Slot?
local SlotGroup = Class {
  init = function(self)
    self.slots = { }
    self.currentSlot = nil
  end
}

function SlotGroup:getType()
  return 'slot_group'
end

---@param slot Slot
---@param positionX number
---@param positionY number
---@param width number
function SlotGroup:addSlot(slot, positionX, positionY, width)
  local slot = Slot(self, positionX, positionY, width)
  lume.push(self.slots, slot)
  return slot
end

---@param index integer
function SlotGroup:getSlotAt(index)
  return self.slots[index]
end

---@param slot Slot
function SlotGroup:setCurrentSlot(slot)
  self.currentSlot = slot
end

function SlotGroup:draw()
  for _, slot in ipairs(self.slots) do
    slot:draw()
  end
end

function SlotGroup:count()
  return lume.count(self.slots)
end

--- gets current slot index, or nil if no current slot
---@return integer?
function SlotGroup:getCurrentSlotIndex()
  local index = lume.find(self.slots, self.currentSlot)
  return index
end

function SlotGroup:getCurrentSlot()
  return self.currentSlot
end

---@return Slot[]
function SlotGroup:getSlots()
  return self.slots
end


return SlotGroup
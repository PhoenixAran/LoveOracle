local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'
local Slot = require 'engine.menus.slot'

local SlotGroup = Class { __includes = SignalObject,
  init = function(self)
    self.slots = { }
    self.currentSlot = nil
  end
}

function SlotGroup:getType()
  return 'slot_group'
end

function SlotGroup:addSlot(x, y, width)
  local slot = Slot(self, x, y, width)
  slot:connect('slotSelected', self, 'onSlotSelected')
  if lume.count(self.slots == 0) then
    self:setCurrentSlot(slot)
  end
  lume.push(self.slots, slot)
end

function SlotGroup:getSlotAt(index)
  return self.slots[index]
end

function SlotGroup:setCurrentSlot(slot)
  self.currentSlot = slot
end

function SlotGroup:getCurrentSlot()
  return self.currentSlot
end

function SlotGroup:getSlots()
  return self.slots
end

function SlotGroup:getCurrentIndex()
  return lume.find(self.slots, self.currentSlot)
end

function SlotGroup:onSlotSelected(slot)
  self:setCurrentSlot(slot)
end 

return SlotGroup
local GameConfig = require 'game_config'
local lume = require 'lib.lume'

---@type string[]
local buttonSlotOrder = { }
for _, buttonSlot in pairs(GameConfig.buttonSlotOrder) do
  lume.push(buttonSlotOrder, buttonSlot)
end

--- utility functions for button slot item logic
--- mainly used for two handed weapon equipment logic
---@class ControlHelper
local ControlHelper = {
}

function ControlHelper.setButtonSlotOrders(newButtonSlotOrder)
  buttonSlotOrder = { }
  for _, buttonSlot in pairs(newButtonSlotOrder) do
    lume.push(buttonSlotOrder, buttonSlot)
  end
end

function ControlHelper.getButtonSlotIndex(slot)
  local slotIndex = lume.indexof(buttonSlotOrder, slot)
  assert(slotIndex, 'Invalid button slot: ' .. slot)
  return slotIndex
end

function ControlHelper.getButtonSlotCount()
  return lume.count(buttonSlotOrder)
end

function ControlHelper.areSlotsAdjacent(slot1, slot2)
  local slot1Index = lume.indexof(buttonSlotOrder, slot1)
  local slot2Index = lume.indexof(buttonSlotOrder, slot2)
  assert(slot1Index, 'Invalid button slot: ' .. slot1)
  assert(slot2Index, 'Invalid button slot: ' .. slot2)
  return math.abs(slot1Index - slot2Index) == 1
end

return ControlHelper
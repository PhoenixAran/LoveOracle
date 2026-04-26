local Class = require 'lib.class'
local lume = require 'lib.lume'
local GameState = require 'engine.control.game_state'
local Input = require('engine.singletons').input
local SlotGroup = require 'engine.control.menu.slot_group'
local Direction4 = require 'engine.enums.direction4'
local AngleSnap = require 'engine.enums.angle_snap'
local SpriteBank = require 'engine.banks.sprite_bank'
local Singletons = require 'engine.singletons'

--- base class you can use for menu states
--- contains convenience methods for navigating between slots and slot groups
---@class BaseMenuState : GameState
---@field slotGroups SlotGroup[]
---@field currentSlotGroup SlotGroup
---@field slotCursor Sprite|CompositeSprite the cursor that is drawn over the currently selected slot
---@field drawLastRoomState boolean whether to draw the last room state in the background when this menu is open. Defaults to true, but can be set to false for menus like the start menu where you don't want to show the game screen in the background
---@field lastRoomState GameState? the last room state
local MenuState = Class { __includes = GameState,
  init = function(self)
    GameState.init(self)
    self.slotGroups = {}
    self.currentSlotGroup = nil
    self.slotCursor = SpriteBank.getSprite('inventory_cursor_hover')
    self.drawLastRoomState = true
  end
}

function MenuState:getType()
  return 'menu_state'
end

function MenuState:getCurrentSlotGroup()
  return self.currentSlotGroup
end

function MenuState:getDirection4FromControl()
  local x, y = Input:get('move')
  x, y = AngleSnap.toVector(AngleSnap.to4, x, y)
  return Direction4.getDirection(x, y)
end

function MenuState:updateSlotTraversal()
  if self.currentSlotGroup then
    self:nextSlot(self:getDirection4FromControl())
  end
end

---@param direction4 Direction4
function MenuState:nextSlot(direction4)
  if self.currentSlotGroup == nil then
    return
  end

  local currentSlot = self.currentSlotGroup:getCurrentSlot()
  if currentSlot == nil then 
    return
  end

  local connection = currentSlot:getConnectionAt(direction4)
  if connection == nil then
    return
  end

  if connection:getType() == 'slot' then
    ---@type Slot
    local slot = connection
    slot:select()
    if not slot:isEnabled() then
      self:nextSlot(direction4)
    end
    -- TODO play audio sound
  else
    -- slot_group
    ---@type SlotGroup
    self.currentSlotGroup = connection
    -- TODO play an audio sound
  end
end

---@param slot Slot
function MenuState:drawSlotCursor(slot)
  local x, y = slot.positionX, slot.positionY
  self.slotCursor:draw(x, y)
end

function MenuState:drawSlots()
  if self.currentSlotGroup then
    self:drawSlotCursor(self.currentSlotGroup:getCurrentSlot())
  end

  for _, slotGroup in ipairs(self.slotGroups) do
    slotGroup:draw()
  end
end

function MenuState:onBegin()
  self.lastRoomState = Singletons.gameControl:getCurrentRoomState()
end

--- draws last room state if drawLastRoomState is true and lastRoomState is not nil
function MenuState:drawLastRoomState()
  if self.lastRoomState and self.drawLastRoomState then
    self.lastRoomState:draw()
  end
end

return MenuState

